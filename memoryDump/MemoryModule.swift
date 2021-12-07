//
//  MemoryModule.swift
//  aftermath
//
//

import Foundation

class MemoryModule {
    
    let caseHandler: CaseHandler
    let memoryDir: URL
    let swapDir: URL
    
    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        self.memoryDir = caseHandler.createNewDir(dirName: "memory")
        self.swapDir = caseHandler.createNewDir(dirName: "memory/swap_raw")
    }
    
    func start() {
        let swap = Swap(caseHandler: caseHandler, memoryDir: self.memoryDir, swapDir: self.swapDir)
        swap.run()
    }
}
