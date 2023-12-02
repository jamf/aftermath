//
//  MemoryModule.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 10/18/23.
//

import Foundation

class MemoryModule: AftermathModule {
    let name = "Memory Module"
    let dirName = "Memory"
    let description = "A module for collecting memory data"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
    func run() {
        self.log("Collecting available memory information")
        
        let stat = Stat()
        stat.run()
    }
}
