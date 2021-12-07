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
    
    init(caseHandler: CaseHandler, browserDir: URL, chromeDir: URL, writeFile: URL) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.chromeDir = chromeDir
        self.fm = FileManager.default
        self.writeFile = writeFile
    }
    
    func run() {
        self.caseHandler.log("Collecting chrome browser information...")
    }
}
