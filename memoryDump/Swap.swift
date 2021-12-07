//
//  Swap.swift
//  aftermath
//
//

import Foundation

class Swap {
    
    let caseHandler: CaseHandler
    let memoryDir: URL
    let swapDir: URL
    let fm: FileManager
    let writeFile: URL
    
    init(caseHandler: CaseHandler, memoryDir: URL, swapDir: URL) {
        self.caseHandler = caseHandler
        self.memoryDir = memoryDir
        self.swapDir = swapDir
        self.fm = FileManager.default
        self.writeFile = self.caseHandler.createNewCaseFile(dirUrl: self.memoryDir, filename: "swap.txt")
    }
    
    func captureSwapFile() {
        let dir = "private/var/vm/"
        let files = fm.filesInDirRecursive(path: dir)
        
        for file in files {
            self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.swapDir)
        }
    }
    
    func run() {
        self.caseHandler.log("Collecting swap files...")
        captureSwapFile()
    }
}
