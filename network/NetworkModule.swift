//
//  NetworkModule.swift
//  aftermath
//
//

import Foundation

class NetworkModule: AftermathModule, AMProto {
    let name = "Network Module"
    var dirName = "Network"
    var description = "A module that provides information about active network data on the system"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
    func run() {
        let writeFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "network.txt")
        let airport = Airport(writeFile: writeFile)
        airport.run()
    }
}

