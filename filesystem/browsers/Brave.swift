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
    
    init(caseHandler: CaseHandler, browserDir: URL, braveDir: URL, writeFile: URL) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.braveDir = braveDir
        self.fm = FileManager.default
        self.writeFile = writeFile
    }
    
    func run() {
        self.caseHandler.log("Collecting brave browser information...")
    }
}
