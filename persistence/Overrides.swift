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
    
    func collectLaunchdOverrides(urlLocations: [URL], capturedFile: URL) {
        for url in urlLocations {
            let plistDict = Aftermath.getPlistAsDict(atUrl: url)
            
            self.copyFileToCase(fileToCopy: url, toLocation: self.saveToRawDir)
            self.addTextToFile(atUrl: capturedFile, text: "\n----- \(url.path) -----\n")
            self.addTextToFile(atUrl: capturedFile, text: plistDict.description)
        }
    }
    
    func collectMdmOverrides(path: String) {
        self.copyFileToCase(fileToCopy: URL(fileURLWithPath: path), toLocation: moduleDirRoot)
    }
    
    override func run() {
        self.log("Collecting all overrides...")

        // launchd overrides
        let capturedOverridesFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "overrides.txt")
        let overrides = filemanager.filesInDirRecursive(path: "/var/db/launchd.db/com.apple.launchd/")
        collectLaunchdOverrides(urlLocations: overrides, capturedFile: capturedOverridesFile)
        
        // mdm overrides
        let mdmOverridesFile = "/Library/Application Support/com.apple.TCC/MDMOverrides.plist"
        collectMdmOverrides(path: mdmOverridesFile)
    }
}
