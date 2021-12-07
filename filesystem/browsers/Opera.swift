//
//  Opera.swift
//  aftermath
//
//

import Foundation

class Opera {
        
    let caseHandler: CaseHandler
    let browserDir: URL
    let operaDir: URL
    let fm: FileManager
    let writeFile: URL
    let appPath: String
    
    init(caseHandler: CaseHandler, browserDir: URL, operaDir: URL, writeFile: URL, appPath: String) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.operaDir = operaDir
        self.fm = FileManager.default
        self.writeFile = writeFile
        self.appPath = appPath
    }
    
    func run() {
        // Check if Opera is installed
        if !aftermath.systemReconModule.installAppsArray.contains(appPath) {
            self.caseHandler.log("Opera not installed. Continuing browser recon...")
            return
        }
        
        self.caseHandler.log("Collecting opera browser information...")
    }
}
