//
//  Chrome.swift
//  aftermath
//
//

import Foundation

class Chrome {
        
    let caseHandler: CaseHandler
    let browserDir: URL
    let chromeDir: URL
    let fm: FileManager
    let writeFile: URL
    let appPath: String
    
    init(caseHandler: CaseHandler, browserDir: URL, chromeDir: URL, writeFile: URL, appPath: String) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.chromeDir = chromeDir
        self.fm = FileManager.default
        self.writeFile = writeFile
        self.appPath = appPath
    }
    
    func run() {
        // Check if Chrome is installed
        if !aftermath.systemReconModule.installAppsArray.contains(appPath) {
            self.caseHandler.log("Chrome not installed. Continuing browser recon...")
            return
        }
        
        self.caseHandler.log("Collecting chrome browser information...")
    }
}
