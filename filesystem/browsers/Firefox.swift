//
//  Firefox.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation
import SQLite3
import AppKit

class Firefox: BrowserModule {
        
    let writeFile: URL
    let firefoxDir: URL
    
    init(firefoxDir: URL, writeFile: URL) {
        self.firefoxDir = firefoxDir
        self.writeFile = writeFile
    }
    
    func getContent() {
        for user in getBasicUsersOnSystem() {
        
            let profiles = "\(user.homedir)/Library/Application Support/Firefox/Profiles"
            let files = filemanager.filesInDirRecursive(path: profiles)
        
            for file in files {
                if file.lastPathComponent == "places.sqlite" {
                    self.copyFileToCase(fileToCopy: file, toLocation: self.firefoxDir, newFileName: "downloads_and_history_\(user.username)")
                    dumpHistory(file: file)
                    dumpDownloads(file: file)
                }
                if file.lastPathComponent == "extensions.json" {
                    self.copyFileToCase(fileToCopy: file, toLocation: self.firefoxDir, newFileName: "extensions_\(user.username)")
                    dumpExtensions(file: file)
                }
            }
        }
    }
    
    func dumpHistory(file: URL) {
        
        let historyOutput = self.createNewCaseFile(dirUrl: self.firefoxDir, filename: "history_output.csv")
        self.addTextToFile(atUrl: historyOutput, text: "datetime,url")
        
        var db: OpaquePointer?
        if sqlite3_open(file.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "SELECT datetime(hv.visit_date/1000000, 'unixepoch') as dt, p.url FROM moz_historyvisits hv INNER JOIN moz_places p ON hv.place_id = p.id ORDER by dt ASC;"
            
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                var dateTime: String = ""
                var url: String = ""
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    if let col1  = sqlite3_column_text(queryStatement, 0) {
                        let unformattedDateTime = String(cString: col1)
                        dateTime = Aftermath.standardizeMetadataTimestamp(timeStamp: unformattedDateTime)
                    }
                    
                    if let col2 = sqlite3_column_text(queryStatement, 1) {
                        url = String(cString: col2)
                    }
                    
                    self.addTextToFile(atUrl: historyOutput, text: "\(dateTime),\(url)")
                }
            }
        }
    }
    
    func dumpDownloads(file: URL) {
        self.addTextToFile(atUrl: self.writeFile, text: "----- Firefox Downloads: -----\n")
        let downloadsOutput = self.createNewCaseFile(dirUrl: self.firefoxDir, filename: "downloads_output.csv")
        self.addTextToFile(atUrl: downloadsOutput, text: "datetime,url,contents")

        
        var db: OpaquePointer?
        if sqlite3_open(file.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "SELECT moz_annos.dateAdded, moz_places.url, moz_annos.content FROM moz_places JOIN moz_annos WHERE moz_places.id = moz_annos.place_id AND anno_attribute_id=1;"
            
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                var dateAdded: String = ""
                var url: String = ""
                var content: String = ""
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let col1  = sqlite3_column_text(queryStatement, 0)
                    if let col1 = col1 {
                        let intDate = Int(String(cString: col1))
                        let secondsConvert = Double(intDate!/1000000)
                        dateAdded = Aftermath.dateFromEpochTimestamp(timeStamp: secondsConvert)
                    }
                    
                    if let col2 = sqlite3_column_text(queryStatement, 1) {
                        url = String(cString: col2)
                    }
                    
                    if let col3 = sqlite3_column_text(queryStatement, 2) {
                        content = String(cString: col3)
                    }
                    
                    self.addTextToFile(atUrl: self.writeFile, text: "DateAdded: \(dateAdded)\nURL: \(url)\nContent: \(content)\n")
                    self.addTextToFile(atUrl: downloadsOutput, text: "\(dateAdded),\(url),\(content)")
                }
            }
        }
        self.addTextToFile(atUrl: self.writeFile, text: "----- End of Firefox Downloads -----")
    }
    
    func dumpExtensions(file: URL) {
        let _ = self.copyFileToCase(fileToCopy: file, toLocation: self.firefoxDir)
        
        do {
            let data = try Data(contentsOf: file, options: .mappedIfSafe)
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] {
                self.addTextToFile(atUrl: writeFile, text: "\nFirefox Extensions -----\n\(String(describing: json))\n ----- End of Firefox Extensions -----\n")
            }
            
        } catch { self.log("Unable to capture Firefox extensions") }
    }
    
    override func run() {
        self.log("Collecting Firefox browser information...")
        getContent()
    }
}

