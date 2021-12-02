//
//  LaunchItems.swift
//  aftermath
//
//
import Foundation

class LaunchItems {
    
    let caseHandler: CaseHandler
    let launchDaemonsPath: String
    let launchAgentsPath: String
    let saveToDir: URL
    let saveToRawDir: URL
    
    init(caseHandler: CaseHandler, saveToDir: URL, saveToRawDir: URL) {
        self.caseHandler = caseHandler
        self.saveToDir = saveToDir
        self.saveToRawDir = saveToRawDir
        self.launchDaemonsPath = "/Library/LaunchDaemons/"
        self.launchAgentsPath = "/Library/LaunchAgents/"
    }
    
    func captureLaunchData(urlLocations: [URL], capturedLaunchFile: URL) {
        for url in urlLocations {
            let plistDict = Aftermath.getPlistAsDict(atUrl: url)
            
            // copy the plists to the persistence directory
            self.caseHandler.copyFileToCase(fileToCopy: url, toLocation: self.saveToRawDir)
            
            // write the plists to one file
            self.caseHandler.addTextToFile(atUrl: capturedLaunchFile, text: "\n----- \(url) -----\n")
            self.caseHandler.addTextToFile(atUrl: capturedLaunchFile, text: plistDict.description)
        }
    }
    
    func run() {
        let capturedLaunchFile = self.caseHandler.createNewCaseFile(dirUrl: self.saveToDir, filename: "launchItems.txt")
        let launchDaemons = FileManager.default.filesInDirRecursive(path: self.launchDaemonsPath)
        let launchAgents = FileManager.default.filesInDirRecursive(path: self.launchAgentsPath)
        
        captureLaunchData(urlLocations: launchDaemons, capturedLaunchFile: capturedLaunchFile)
        captureLaunchData(urlLocations: launchAgents, capturedLaunchFile: capturedLaunchFile)
    }
    
    // TODO
    //func pivotToBinary(binaryUrl: URL) { }
    
}
