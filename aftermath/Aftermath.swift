//
//  Aftermath.swift
//  aftermath
//
//

import Foundation
import SwiftCSV

class Aftermath {
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
    
    static func getPlistAsDict(atUrl: URL) -> [String: Any] {
        var data = Data()
        var plistDict = [String:Any]()
        
        if FileManager.default.fileExists(atPath: atUrl.relativePath) {
            do {
                data = try Data(contentsOf: atUrl)
                plistDict = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:Any]
            } catch {
                print("Could not read \(atUrl.relativePath) due to \(error)")
            }
        }
        
        return plistDict
    }
    
    static func dateFromEpochTimestamp(timeStamp: Double) -> String {
        
        let date = NSDate(timeIntervalSince1970: timeStamp)
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let dateString = dateFormatter.string(from: date as Date)
        return dateString
    }
    
    
    static func readCSVRows(path: String) -> NamedCSV {

        do {
            let csvFile = try NamedCSV(url: URL(fileURLWithPath: path), delimiter: .comma, encoding: .utf8)
            return csvFile
           
        } catch {
            print(error)
            exit(1)
        }
    }
}
