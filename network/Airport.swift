//
//  Airport.swift
//  aftermath
//
//

import Foundation


class Airport: NetworkModule {
    let writeFile: URL
    
    init(writeFile: URL) {
        self.writeFile = writeFile
    }
    
    func captureAirportPrefs() {
        let url = URL(fileURLWithPath: "/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist")
        let plistDict = Aftermath.getPlistAsDict(atUrl: url)
        
        self.copyFileToCase(fileToCopy: url, toLocation: moduleDirRoot)
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- \(url) -----\n\(plistDict)\n")
    }
    
    override func run() {
        self.log("Collecting airport information...")
        captureAirportPrefs()
    }
}

