//
//  LSQuarantine.swift
//  aftermath
//
//

import Foundation
import SQLite3


class LSQuarantine: ArtifactsModule {
    

    let rawDir: URL
    
    init(rawDir: URL) {
        self.rawDir = rawDir
    }
    
    func getLSQuarantine() {
 
        var fileURL: URL
        for user in getBasicUsersOnSystem() {
            if (user.username == "root") { continue }
            
            fileURL = URL(fileURLWithPath: "\(user.homedir)/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2")
            self.copyFileToCase(fileToCopy: fileURL, toLocation: self.rawDir, newFileName: "lsquarantine_\(user.username)")
        }
    }
    
    override func run() {
        self.log("Capturing raw LSQuarantine data...")
        getLSQuarantine()
    }
}

