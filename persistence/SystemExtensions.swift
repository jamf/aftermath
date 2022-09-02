//
//  SystemExtensions.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class SystemExtensions: PersistenceModule {
    
    let saveToRawDir: URL
    
    init(saveToRawDir: URL) {
        self.saveToRawDir = saveToRawDir
    }
    
    func captureSysExtensions(urlLocations: [URL], rawLoc: URL) {
        let capturedSystemExtensions = self.createNewCaseFile(dirUrl: self.moduleDirRoot, filename: "systemExtensions.txt")
        self.addTextToFile(atUrl: capturedSystemExtensions, text: "System Extension URLs\n\n")
        for url in urlLocations {
            self.addTextToFile(atUrl: capturedSystemExtensions, text: "\(url.path)\n")
        }
    }
    
    override func run() {
        self.log("Writing system extension urls...")

        let sysExtensionsRaw = self.createNewDir(dir: self.saveToRawDir, dirname: "systemExtensions_dump")
        
        let sysExtensions = filemanager.filesInDirRecursive(path: "/Library/SystemExtensions/")
        
        captureSysExtensions(urlLocations: sysExtensions, rawLoc: sysExtensionsRaw)
    }
}
