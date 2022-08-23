//
//  Airport.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation


class NetworkConnections: NetworkModule {
    
    let rawDir: URL
   
    init(rawDir: URL) {
        self.rawDir = rawDir
    }
    
    func captureAirportPrefs(writeFile: URL) {
        let url = URL(fileURLWithPath: "/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist")
        let plistDict = Aftermath.getPlistAsDict(atUrl: url)
        
        self.copyFileToCase(fileToCopy: url, toLocation: rawDir)
        self.addTextToFile(atUrl: writeFile, text: "\(url.path)\n\(plistDict)\n")
    }
    
    func captureNetworkConnections(writeFile: URL) {
        let command = "lsof -i"
        let output = Aftermath.shell("\(command)")
        
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

