//
//  XProtect.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 7/25/23.
//

import Foundation

@available(macOS 13, *)
class XProtectBehavioralService: ArtifactsModule {
    
    let xbsDir: URL
    
    init(xbsDir: URL) {
        self.xbsDir = xbsDir
    }
    
    func collectXprotectDb() {
        let xprotectPath = URL(fileURLWithPath: "/var/protected/xprotect/XPdb")
        
        if (filemanager.fileExists(atPath: xprotectPath.path)) {
            self.copyFileToCase(fileToCopy: xprotectPath, toLocation: self.xbsDir)
        }
    }
    
    override func run() {
        collectXprotectDb()
    }
}
