//
//  Aftermath.swift
//  aftermath
//
//  Created by Matt Benyo on 11/30/21.
//

import Foundation

class Aftermath {
    init(){
        
    }
    
    //function for calling bash commands
    static func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/bash"
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }
}
