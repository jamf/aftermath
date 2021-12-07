//
//  Safari.swift
//  aftermath
//
//

import Foundation

class Safari {
        
    let caseHandler: CaseHandler
    let browserDir: URL
    let safariDir: URL
    let fm: FileManager
    let writeFile: URL
    let appPath: String
    
    init(caseHandler: CaseHandler, browserDir: URL, safariDir: URL, writeFile: URL, appPath: String) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.safariDir = safariDir
        self.fm = FileManager.default
        self.writeFile = writeFile
        self.appPath = appPath
    }
    
    func run() {
        // Check if Safari is installed
        if !aftermath.systemReconModule.installAppsArray.contains(appPath) {
            self.caseHandler.log("Safari not installed. Continuing browser recon...")
            return
        }
        
        self.caseHandler.log("Collecting safari browser information...")
    }
}
