//
//  TCC.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation
import SQLite3
import AppKit

class TCC: ArtifactsModule {
    
    let tccDir: URL
    
    init(tccDir: URL) {
        self.tccDir = tccDir
    }
        
    func getTCC() {

        
        var tcc_paths = [URL(fileURLWithPath: "/Library/Application Support/com.apple.TCC/TCC.db")]
        
        for user in getBasicUsersOnSystem() {
            let tcc_path = URL(fileURLWithPath:"\(user.homedir)/Library/Application Support/com.apple.TCC/TCC.db")
            if !filemanager.fileExists(atPath: tcc_path.relativePath) { continue }

            tcc_paths.append(tcc_path)
        }
        
        for tcc_path in tcc_paths {
            var appendedName: String
            if tcc_path.pathComponents[1] == "Library" {
                appendedName = "root"
            } else {
                appendedName = tcc_path.pathComponents[2]
            }
            
            self.copyFileToCase(fileToCopy: tcc_path, toLocation: tccDir, newFileName: "tcc_\(appendedName)")
            
            self.log("Finished TCC query on TCC database for \(appendedName)")
        }
    
        self.log("Finished collecting raw TCC")
    }
    
    override func run() {
        self.log("Collecting raw TCC information...")
        getTCC()
        
    }
}
