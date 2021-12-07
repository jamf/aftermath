//
//  Airport.swift
//  aftermath
//
//

import Foundation

class Airport {
    
    let caseHandler: CaseHandler
    let networkDir: URL
    let writeFile: URL
    
    init(caseHandler: CaseHandler, networkDir: URL, writeFile: URL) {
        self.caseHandler = caseHandler
        self.networkDir = networkDir
        self.writeFile = writeFile
    }
    
    func captureAirportPrefs() {
        let url = URL(fileURLWithPath: "/Library/Preferences/SystemConfiguration/com.apple.airport.preferences.plist")
        let plistDict = Aftermath.getPlistAsDict(atUrl: url)
        
        self.caseHandler.copyFileToCase(fileToCopy: url, toLocation: self.networkDir)
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "\n----- \(url) -----\n\(plistDict)\n")
    }
    
    func run() {
        self.caseHandler.log("Collecting airport information...")
        captureAirportPrefs()
    }
}
