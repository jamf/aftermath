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
                if file.lastPathComponent == "cookies.sqlite" {
                    self.copyFileToCase(fileToCopy: file, toLocation: self.firefoxDir, newFileName: "cookies_\(user.username)")
                    dumpCookies(file: file)
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
                        dateTime = String(cString: col1)
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
        
        var db: OpaquePointer?
        if sqlite3_open(file.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "SELECT moz_annos.dateAdded, moz_annos.content, moz_places.url FROM moz_annos, moz_places WHERE moz_places.id = moz_annos.place_id AND anno_attribute_id=1;"
            
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                var dateAdded: String = ""
                var content: String = ""
                var url: String = ""
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    if let col1  = sqlite3_column_text(queryStatement, 0) {
                        dateAdded = String(cString: col1)
                    }
                    
                    if let col2 = sqlite3_column_text(queryStatement, 1) {
                        content = String(cString: col2)
                    }
                    
                    if let col3 = sqlite3_column_text(queryStatement, 2) {
                        url = String(cString: col3)
                    }
                    
                    self.addTextToFile(atUrl: self.writeFile, text: "DateAdded: \(dateAdded)\nURL: \(url)\nContent: \(content)\n")
                }
            }
        }
        self.addTextToFile(atUrl: self.writeFile, text: "----- End of Firefox Downloads -----")
    }
    
    func dumpCookies(file: URL) {
        self.addTextToFile(atUrl: self.writeFile, text: "----- Firefox Cookies: -----\n")

        for user in getBasicUsersOnSystem() {
        
            let file = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/BraveSoftware/Brave-Browser/Default/Cookies")
                        
            var db: OpaquePointer?
            if sqlite3_open(file.path, &db) == SQLITE_OK {
                var queryStatement: OpaquePointer? = nil
                let queryString = "select datetime(creation_utc/1000000-11644473600, 'unixepoch'), name,  host_key, path, datetime(expires_utc/1000000-11644473600, 'unixepoch') from cookies;"
            
                if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                    var dateTime: String = ""
                    var name: String = ""
                    var hostKey: String = ""
                    var path: String = ""
                    var expireTime: String = ""
                    
                    while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let col1  = sqlite3_column_text(queryStatement, 0)
                        if let col1 = col1 { dateTime = String(cString: col1) }
                        
                        let col2 = sqlite3_column_text(queryStatement, 1)
                        if let col2 = col2 { name = String(cString: col2) }
                        
                        let col3 = sqlite3_column_text(queryStatement, 2)
                        if let col3 = col3 { hostKey = String(cString: col3) }
                        
                        let col4 = sqlite3_column_text(queryStatement, 3)
                        if let col4 = col4 { path = String(cString: col4) }
                        
                        let col5 = sqlite3_column_text(queryStatement, 4)
                        if let col5 = col5 { expireTime = String(cString: col5) }
                        
                        self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nName: \(name)\nHostKey: \(hostKey)\nPath:\(path)\nExpireTime: \(expireTime)\n\n")
                    }
                }
            }
        }
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- End of Firefox Cookies -----\n")
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

