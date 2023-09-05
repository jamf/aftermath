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
        let network = NetworkConnections()
        network.run()
        
        
    }
    
    func pcapRun() {
        let pcapWriteFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "trace.pcap")
        let network = NetworkConnections()
        
        network.pcapCapture(writeFile: pcapWriteFile)
    }
}

