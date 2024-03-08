//
//  ESModule.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 6/6/23.
//

import Foundation

import Foundation

class ESModule: AftermathModule {
    
    let name = "EndpointSecurity"
    var dirName = "EndpointSecurity"
    var description = "A module that performs endpoint security captures"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    lazy var esFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "es_logs.json")
    
    func run() {
        if Command.disableFeatures["proc-info"] == false {
            self.log("Starting ES logging...")
            let esLogs = ESLogs(outputDir: moduleDirRoot, outputFile: esFile)
            esLogs.run()
        } else {
            self.log("Skipping ES logging")
        }
    }
}
