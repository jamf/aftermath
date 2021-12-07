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
    
    init(caseHandler: CaseHandler, browserDir: URL, safariDir: URL, writeFile: URL) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.safariDir = safariDir
        self.fm = FileManager.default
        self.writeFile = writeFile
    }
    
    func run() {
        self.caseHandler.log("Collecting safari browser information...")
    }
}
