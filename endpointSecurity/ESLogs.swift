//
//  ESLogs.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 6/6/23.
//

import Foundation

class ESLogs: ESModule {
    
    let outputDir: URL
    let outputFile: URL
    
    init(outputDir: URL, outputFile: URL) {
        self.outputDir = outputDir
        self.outputFile = outputFile
    }
    
    // Note: Because eslogger runs on a separate thread, it will exit when aftermath exits, which may cause the last line of the json file to be truncated/incomplete.
    func logESEvents(events: String) {
        var output = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let command = "eslogger \(events) > \(self!.outputFile.relativePath)"
            output = Aftermath.shell("\(command)")
            
            return
        }
        
        self.addTextToFile(atUrl: self.outputFile, text: output)
    }
    
    override func run() {
        self.log("Collecting ES logs...")
        logESEvents(events: Command.esLogs.joined(separator: " "))
    }
}
