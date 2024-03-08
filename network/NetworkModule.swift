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
        self.log("Started gathering network information...")

        let network = NetworkConnections()
        network.run()
        
        self.log("Finished gathering network information...")
    }
    
    func pcapRun() {
        self.log("Running pcap...")

        let pcapWriteFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "trace.pcap")
        let network = NetworkConnections()
        
        network.pcapCapture(writeFile: pcapWriteFile)
    }
}

