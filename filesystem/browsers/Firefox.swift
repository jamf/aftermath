//
//  Firefox.swift
//  aftermath
//
//

import Foundation
import SQLite3
import AppKit

class Firefox {
        
    let caseHandler: CaseHandler
    let browserDir: URL
    let firefoxDir: URL
    let fm: FileManager
    let writeFile: URL
    let appPath: String
    
    init(caseHandler: CaseHandler, browserDir: URL, firefoxDir: URL, writeFile: URL, appPath: String) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.firefoxDir = firefoxDir
        self.fm = FileManager.default
        self.writeFile = writeFile
        self.appPath = appPath
    }
    
    func getContent() {
        let username = NSUserName()
        let profiles = "/Users/\(username)/Library/Application Support/Firefox/Profiles"
        let files = fm.filesInDirRecursive(path: profiles)
    
        for file in files {
            if file.lastPathComponent == "places.sqlite" {
                dumpHistory(file: file)
                dumpDownloads(file: file)
            }
            if file.lastPathComponent == "cookies.sqlite" {
                dumpCookies(file: file)
            }
            if file.lastPathComponent == "extensions.json" {
                dumpExtensions(file: file)
            }
        }
    }
    
    func dumpHistory(file: URL) {
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "\n----- Firefox History: -----\n")
        
        var db: OpaquePointer?
        if sqlite3_open(file.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "SELECT datetime(hv.visit_date/1000000, 'unixepoch') as dt, p.url FROM moz_historyvisits hv INNER JOIN moz_places p ON hv.place_id = p.id ORDER by dt ASC;"
            
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                var dateTime: String = ""
                var url: String = ""
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let col1  = sqlite3_column_text(queryStatement, 0)
                    if col1 != nil {
                        dateTime = String(cString: col1!)
                    }
                    
                    let col2 = sqlite3_column_text(queryStatement, 1)
                    if col2 != nil {
                        url = String(cString: col2!)
                    }
                    
                    self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nURL: \(url)\n")
                }
            }
        }
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "----- End of Firefox History -----")
    }
    
    func dumpDownloads(file: URL) {
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "----- Firefox Downloads: -----\n")
        
        var db: OpaquePointer?
        if sqlite3_open(file.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "SELECT moz_annos.dateAdded, moz_annos.content, moz_places.url FROM moz_annos, moz_places WHERE moz_places.id = moz_annos.place_id AND anno_attribute_id=1;"
            
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                var dateAdded: String = ""
                var content: String = ""
                var url: String = ""
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let col1  = sqlite3_column_text(queryStatement, 0)
                    if col1 != nil {
                        dateAdded = String(cString: col1!)
                    }
                    
                    let col2 = sqlite3_column_text(queryStatement, 1)
                    if col2 != nil {
                        content = String(cString: col2!)
                    }
                    
                    let col3 = sqlite3_column_text(queryStatement, 2)
                    if col3 != nil {
                        url = String(cString: col3!)
                    }
                    
                    self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "DateAdded: \(dateAdded)\nURL: \(url)\nContent: \(content)\n")
                }
            }
        }
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "----- End of Firefox Downloads -----")
    }
    
    func dumpCookies(file: URL) {
        let username = NSUserName()
        let file = URL(fileURLWithPath: "/Users/\(username)/Library/Application Support/BraveSoftware/Brave-Browser/Default/Cookies")
        
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "----- Brave Cookies: -----\n")
        
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
                    if col1 != nil {
                        dateTime = String(cString: col1!)
                    }
                    
                    let col2 = sqlite3_column_text(queryStatement, 1)
                    if col2 != nil {
                        name = String(cString: col2!)
                    }
                    
                    let col3 = sqlite3_column_text(queryStatement, 2)
                    if col3 != nil {
                        hostKey = String(cString: col1!)
                    }
                    
                    let col4 = sqlite3_column_text(queryStatement, 3)
                    if col4 != nil {
                        path = String(cString: col2!)
                    }
                    
                    let col5 = sqlite3_column_text(queryStatement, 4)
                    if col5 != nil {
                        expireTime = String(cString: col1!)
                    }
                    
                    self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nName: \(name)\nHostKey: \(hostKey)\nPath:\(path)\nExpireTime: \(expireTime)\n\n")
                }
            }
        }
        
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "\n----- End of Brave Cookies -----\n")
    }
    
    func dumpExtensions(file: URL) {
        let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.firefoxDir)
        
        do {
            let data = try Data(contentsOf: file, options: .mappedIfSafe)
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] {
                self.caseHandler.addTextToFile(atUrl: writeFile, text: "\nFirefox Extensions -----\n\(String(describing: json))\n ----- End of Firefox Extensions -----\n")
            }
            
        } catch { self.caseHandler.log("Unable to capture Firefox extensions") }
    }
    
    func run() {
        self.caseHandler.log("Collecting firefox browser information...")
        getContent()
    }
}
