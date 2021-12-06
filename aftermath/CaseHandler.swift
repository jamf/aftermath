//
//  CaseHandler.swift
//  aftermath
//
//

import Foundation

class CaseHandler {
    let hostName = Host.current().localizedName ?? ""
    let starttime = Date().ISO8601Format()
    let caseDir: URL
    let logFile: URL
    
    init() {
        let caseName = "Aftermath_\(hostName)_\(starttime)"
        self.caseDir = URL(fileURLWithPath: "/tmp/\(caseName)")
        self.logFile = caseDir.appendingPathComponent("aftermath.log")
        self.setup()
    }
    
    private func setup() {
        self.createCaseDir()
        let _ = self.createNewCaseFile(dirUrl: self.caseDir, filename: "aftermath.log")
    }
    
    private func createCaseDir() {
        do {
            try FileManager.default.createDirectory(at: caseDir, withIntermediateDirectories: true, attributes: nil)
            print("Response directory created at \(caseDir.relativePath)")
        } catch {
            print(error)
        }
    }
    
    func createNewDir(dirName: String) -> URL {
        let newUrl = self.caseDir.appendingPathComponent(dirName)
        
        do {
            try FileManager.default.createDirectory(at: newUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
        
        return newUrl
    }
    
    func createNewCaseFile(dirUrl: URL, filename: String) -> URL {
        let newFile = dirUrl.appendingPathComponent(filename)
        let path = newFile.relativePath
        if !(FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)) {
            print("\(Date().ISO8601Format()) - Error creating \(self.logFile)")
        }
        
        return newFile
    }
    
    func addTextToFile(atUrl: URL, text: String) {
        let textWithNewLine = "\(text)\n"
        do {
            let fileHandle = try FileHandle(forWritingTo: atUrl)
                fileHandle.seekToEndOfFile()
                fileHandle.write(textWithNewLine.data(using: .utf8)!)
                fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
        }
    }
    
    func addTextToFileFromUrl(fromFile: URL, toFile: URL) {
        do {
            let contents = try String(contentsOf: fromFile, encoding: .utf8)
            self.addTextToFile(atUrl: toFile, text: "\(fromFile):\n\n\(contents)\n----------\n")
        } catch {
            self.log("\(Date().ISO8601Format())-  Unable to writing contents of \(fromFile) to \(toFile) due to error:\n\(error) ")
        }
    }
    
    func copyFileToCase(fileToCopy: URL, toLocation: URL?) {
        var to = self.caseDir
        if let toLocation = toLocation { to = toLocation }
        
        let filename = fileToCopy.lastPathComponent
        let dest = to.appendingPathComponent(filename)
        
        do {
            try FileManager.default.copyItem(at:fileToCopy, to:dest)

        } catch {
            print("\(Date().ISO8601Format()) - Error copying \(fileToCopy.relativePath) to case directory")
        }
        
    }
    
    func log(_ note: String, displayOnly: Bool = false, file: String = #file) {
        let module = URL(fileURLWithPath: file).lastPathComponent
        let entry = "\(Date().ISO8601Format()) - \(module) - \(note)"
        print(entry)
        if displayOnly == false {
            addTextToFile(atUrl: self.logFile, text: entry)
        }
    }
}
