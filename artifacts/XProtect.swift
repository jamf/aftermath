//
//  XProtect.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 7/25/23.
//

import Foundation

@available(macOS 13, *)
class XProtect: ArtifactsModule {
    
    let xprotectDir: URL
    
    init(xprotectDir: URL) {
        self.xprotectDir = xprotectDir
    }
    
    func collectXprotectDb() {
        let xprotectPath = URL(fileURLWithPath: "/var/protected/xprotect/XPdb")
        
        if (filemanager.fileExists(atPath: xprotectPath.path)) {
            self.copyFileToCase(fileToCopy: xprotectPath, toLocation: self.xprotectDir)
        }
    }
    
    override func run() {
        collectXprotectDb()
    }
}
