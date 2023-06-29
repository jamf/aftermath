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
    
    func logESEvents(events: String) {
        var output = ""
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let command = "sudo eslogger \(events) > \(self!.outputFile.relativePath)"
            output = Aftermath.shell("\(command)")
            
            return
        }
        
        self.addTextToFile(atUrl: self.outputFile, text: output)
    }
    
    override func run() {
        if !Command.options.contains(.disableESLogs) {          
            self.log("Collecting ES logs...")
            logESEvents(events: Command.esLogs.joined(separator: " "))
        } else {
            self.log("Skipping ES logging")
        }
    }
}
