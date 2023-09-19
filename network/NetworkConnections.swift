//
//  Airport.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation


class NetworkConnections: NetworkModule {
    
    func captureAirportPrefs(writeFile: URL) {
        let url = URL(fileURLWithPath: "/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist")
        let plistDict = Aftermath.getPlistAsDict(atUrl: url)
        
        self.copyFileToCase(fileToCopy: url, toLocation: self.moduleDirRoot)
        self.addTextToFile(atUrl: writeFile, text: "\(url.path)\n\(plistDict)\n")
    }
    
    func captureNetworkConnections(writeFile: URL) {
        let command = "lsof -i -n"
        let output = Aftermath.shell("\(command)")
        
        self.addTextToFile(atUrl: writeFile, text: output)
    }
    
    // Note: Because tcpdump runs on a separate thread, it will exit when aftermath exits, which may cause the last line of the pcap file to be truncated/incomplete.
    func pcapCapture(writeFile: URL) {
        var output = ""
        DispatchQueue.global(qos: .userInitiated).async {
            let command = "tcpdump -i en0 -w \(writeFile.relativePath)"
            output = Aftermath.shell("\(command)")
            
            return
        }
        
        self.addTextToFile(atUrl: writeFile, text: output)
    }
    
    
    override func run() {
        let airportWriteFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "network.txt")
        let networkConnectionsWriteFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "lsof_output.txt")
        
        self.log("Collecting airport information...")
        captureAirportPrefs(writeFile: airportWriteFile)
        
        self.log("Gathering results of lsof...")
        captureNetworkConnections(writeFile: networkConnectionsWriteFile)
    }
}

