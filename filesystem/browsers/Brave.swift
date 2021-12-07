//
//  Brave.swift
//  aftermath
//
//

import Foundation

class Brave {
        
    let caseHandler: CaseHandler
    let browserDir: URL
    let braveDir: URL
    let fm: FileManager
    let writeFile: URL
    let appPath: String
    
    init(caseHandler: CaseHandler, browserDir: URL, braveDir: URL, writeFile: URL, appPath: String) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.braveDir = braveDir
        self.fm = FileManager.default
        self.writeFile = writeFile
        self.appPath = appPath
    }
    
    func run() {
        // Check if Brave is installed
        if !aftermath.systemReconModule.installAppsArray.contains(appPath) {
            self.caseHandler.log("Brave Browser not installed. Continuing browser recon...")
            return
        }
        
        self.caseHandler.log("Collecting brave browser information...")
    }
}
