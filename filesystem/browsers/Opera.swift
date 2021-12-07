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
    
    init(caseHandler: CaseHandler, browserDir: URL, operaDir: URL, writeFile: URL) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.operaDir = operaDir
        self.fm = FileManager.default
        self.writeFile = writeFile
    }
    
    func run() {
        self.caseHandler.log("Collecting opera browser information...")
    }
}
