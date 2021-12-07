//
//  Firefox.swift
//  aftermath
//
//

import Foundation

class Firefox {
        
    let caseHandler: CaseHandler
    let browserDir: URL
    let firefoxDir: URL
    let fm: FileManager
    let writeFile: URL
    let firefoxAppPath: String = "/Applications/Firefox.app"
    
    init(caseHandler: CaseHandler, browserDir: URL, firefoxDir: URL, writeFile: URL) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.firefoxDir = firefoxDir
        self.fm = FileManager.default
        self.writeFile = writeFile
    }
    
    
    
    func run() {
        // Check if Firefox is installed
        if !aftermath.systemReconModule.installAppsArray.contains("/Applications/Firefox.app") {
            self.caseHandler.log("Firefox not installed. Continuing browser recon...")
            return
        }
        
        
    }
}
