//
//  Stat.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 10/18/23.
//

import Foundation

class Stat: MemoryModule {

    private func scannerModule(inputString: String, stringToFind: String) -> Double? {
        let scanner = Scanner(string: inputString)
        
        if scanner.scanUpTo(stringToFind, into: nil),
           scanner.scanString(stringToFind, into: nil) {
            var result: Double = 0.0
            
            if scanner.scanDouble(&result) {
                return result
            }
        }
        return nil
    }
    
    override func run() {
        
        let writeFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "memory_usage.txt")
        
        // trim extra characters from output
        var trimSet = CharacterSet.whitespacesAndNewlines
        trimSet.insert(charactersIn: "\"")
        
        // create vm_stat shell
        let command = "vm_stat"
        let vmstatOutput = Aftermath.shell(command)
        
        // convert bytes to GiB
        let byteConverter = 0.00000000093132257
        
        // pagesize
        var pagesizeOutput = Aftermath.shell("pagesize")
        pagesizeOutput = pagesizeOutput.trimmingCharacters(in: trimSet)
        let pagesizeDouble = Double(pagesizeOutput)
        
        // parse vm_stat output
        var componentDict = [String:Double]()
        let vmLines = vmstatOutput.split(separator: "\n")
        for l in vmLines {
            let components = l.split(separator: ":")
            
            if components.count == 2 {
                let key = components[0].trimmingCharacters(in: trimSet)
                let value = components[1].trimmingCharacters(in: trimSet)
                let valueDouble = Double(value)
                let updatedValue = valueDouble ?? 0 * pagesizeDouble!
                componentDict[key] = updatedValue
            }
        }
        
        // app memory
        let appMemory = (componentDict["Anonymous pages"] ?? 0.0) - (componentDict["Pages purgeable"] ?? 0.0)
        let wired = Double(componentDict["Pages wired down"]!)
        let active = Double(componentDict["Pages active"]!)
        let inactive = Double(componentDict["Pages inactive"]!)
        let spec = Double(componentDict["Pages speculative"]!)
        let throttled = Double(componentDict["Pages throttled"]!)
        let freeMemory = Double(componentDict["Pages free"]!)
        let purgeable = Double(componentDict["Pages purgeable"]!)
        let compressed = Double(componentDict["Pages occupied by compressor"]!)
        let tradTotal = ((wired + active + inactive + spec + throttled + freeMemory + compressed) * pagesizeDouble!) * byteConverter
        let fileBacked = Double(componentDict["File-backed pages"]!)
        let physicalTotal = ((appMemory + wired + compressed + fileBacked + purgeable + freeMemory) * pagesizeDouble!) * byteConverter
        
        // swap usage
        let vmSwapUsageOutput = Aftermath.shell("sysctl vm.swapusage")
        
        if let vmSwapUsage = scannerModule(inputString: vmSwapUsageOutput, stringToFind: "used = ") {
            self.addTextToFile(atUrl: writeFile, text: "Swap used: \(vmSwapUsage * 0.0009765625)\n")
        }
        
        // memory pressure
        let memoryPressureOutput = Aftermath.shell("memory_pressure")
        if let memoryPressure = scannerModule(inputString: memoryPressureOutput, stringToFind: "percentage: ") {
            self.addTextToFile(atUrl: writeFile, text: "Memory Pressure: \(100 - memoryPressure)%")
        }
        
        // write out
        self.addTextToFile(atUrl: writeFile, text: "\nTraditional Memory:\nWired Memory: \(wired)\nActive Memory: \(active)\nInactive Memory: \(inactive)\nPages Speculative: \(spec)\nPages Throttled: \(throttled)\nPurgeable: \(purgeable)\nCompressed: \(compressed)\nFree Memory: \(freeMemory)\nTotal: \(String(format: "%.2f", tradTotal))GiB\n")
        self.addTextToFile(atUrl: writeFile, text: "\nActivity Monitor Memory:\nApp Memory: \(appMemory)\nWired: \(wired)\nCompressed: \(compressed)\nMemory Used: \(appMemory + wired + compressed)\nCached files: \(fileBacked + purgeable)\nTotal Physical: \(String(format: "%.2f", physicalTotal))GiB\n")
    }
}
