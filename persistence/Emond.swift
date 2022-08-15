//
//  SystemExtensions.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 4/6/22.
//

import Foundation

class Emond: PersistenceModule {
    
    let saveToRawDir: URL
    
    init(saveToRawDir: URL) {
        self.saveToRawDir = saveToRawDir
    }
    
    func captureEmond(urlLocations: [URL], rawLoc: URL) {
        for url in urlLocations {
            self.copyFileToCase(fileToCopy: url, toLocation: rawLoc)
        }
    }
    
    override func run() {
        self.log("Writing emond.d")
        
        let emondRaw = self.createNewDir(dir: self.saveToRawDir, dirname: "emond")
        let emond = filemanager.filesInDirRecursive(path: "/etc/emond.d/")
        
        captureEmond(urlLocations: emond, rawLoc: emondRaw)
    }
}
