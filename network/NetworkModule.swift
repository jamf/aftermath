//
//  NetworkModule.swift
//  aftermath
//
//

import Foundation

class NetworkModule {
    
    let caseHandler: CaseHandler
    let networkDir: URL
    let writeFile: URL
    
    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        self.networkDir = caseHandler.createNewDir(dirName: "network")
        self.writeFile = caseHandler.createNewCaseFile(dirUrl: self.networkDir, filename: "network.txt")
    }
    
    func start() {
        let airport = Airport(caseHandler: caseHandler, networkDir: self.networkDir, writeFile: self.writeFile)
        airport.run()
    }
}
