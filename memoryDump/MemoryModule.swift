//
//  MemoryModule.swift
//  aftermath
//
//

import Foundation


class MemoryModule: AftermathModule, AMProto {
    // All data this module collects so far is encrypted.
    // We either have to research if there is anything to be done or remove it
    let name = "Memory Module"
    let dirName = "Memory"
    var description = "A module that collects artifacts tied to system memory"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
    
    func run() {
        let swapDir = self.createNewDirInRoot(dirName: "\(dirName)/raw")
        let swap = Swap(swapDir: swapDir)
        swap.run()
    }
}
