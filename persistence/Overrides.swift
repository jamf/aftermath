//
//  Overrides.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class Overrides: PersistenceModule {
    
    let saveToRawDir: URL
    
    init(saveToRawDir: URL) {
        self.saveToRawDir = saveToRawDir
    }
    
    func collectOverrides(urlLocations: [URL], capturedFile: URL) {
        for url in urlLocations {
            let plistDict = Aftermath.getPlistAsDict(atUrl: url)
            
            self.copyFileToCase(fileToCopy: url, toLocation: self.saveToRawDir)
            self.addTextToFile(atUrl: capturedFile, text: "\n----- \(url) -----\n")
            self.addTextToFile(atUrl: capturedFile, text: plistDict.description)
        }
    }
    
    override func run() {
        self.log("Collecting overrides...")

        let capturedOverridesFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "overrides.txt")
        
        let overrides = filemanager.filesInDirRecursive(path: "/var/db/launchd.db/com.apple.launchd/")
        
        collectOverrides(urlLocations: overrides, capturedFile: capturedOverridesFile)
        
    }
}
