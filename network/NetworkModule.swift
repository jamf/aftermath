//
//  NetworkModule.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class NetworkModule: AftermathModule, AMProto {
    let name = "Network Module"
    var dirName = "Network"
    var description = "A module that provides information about active network data on the system"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
    func run() {
        
        let rawDir = self.createNewDir(dir: self.moduleDirRoot, dirname: "raw")
        
        let network = NetworkConnections(rawDir: rawDir)
        network.run()
        
        
    }
}

