//
//  Aftermath.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC


import Foundation
import SwiftCSV

class Aftermath {

    static var fm: FileManager = .default

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
        
        if fm.fileExists(atPath: atUrl.relativePath) {
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
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        let dateString = dateFormatter.string(from: date as Date)
        return dateString
    }
    
    static func standardizeMetadataTimestamp(timeStamp: String) -> String {
        // yyyy-MM-dd'T'HH:mm:ss
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" //"yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        
        if let date = dateFormatter.date(from: timeStamp) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let dateString = dateFormatter.string(from: date as Date)
            return dateString
        }
            
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        if let date = dateFormatter.date(from: timeStamp) {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let dateString = dateFormatter.string(from: date as Date)
            return dateString
        } else {
            return "unknown"
        }
        
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
    
    
    static func sortCSV(unsortedArr: [[String]]) throws -> [[String]] {
        var arr = unsortedArr
        try arr.sort { lhs, rhs in
            guard let lhsStr = lhs.first, let rhsStr = rhs.first else { return false }
            let lhsDate = try Date("\(lhsStr)Z", strategy: .iso8601)
            let rhsDate = try Date("\(rhsStr)Z", strategy: .iso8601)
            return lhsDate > rhsDate
        }
        return arr
    }
}
