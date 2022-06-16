//
//  SystemExtensions.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 4/6/22.
//

import Foundation

class SystemExtensions: PersistenceModule {
    
    let saveToRawDir: URL
    
    init(saveToRawDir: URL) {
        self.saveToRawDir = saveToRawDir
    }
    
    func captureSysExtensions(urlLocations: [URL], rawLoc: URL) {
        let capturedSystemExtensions = self.createNewCaseFile(dirUrl: self.moduleDirRoot, filename: "systemExtensions.txt")
        self.addTextToFile(atUrl: capturedSystemExtensions, text: "System Extension URLs\n-----\n\n")
        for url in urlLocations {
            self.addTextToFile(atUrl: capturedSystemExtensions, text: "\(url.absoluteString)\n")
        }
    }
    
    override func run() {
        self.log("Writing system extension urls...")

        let sysExtensionsRaw = self.createNewDir(dir: self.saveToRawDir, dirname: "systemExtensions_dump")
        
        let sysExtensions = filemanager.filesInDirRecursive(path: "/Library/SystemExtensions/")
        
        captureSysExtensions(urlLocations: sysExtensions, rawLoc: sysExtensionsRaw)
    }
}
