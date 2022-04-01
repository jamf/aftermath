//
//  Brave.swift
//  aftermath
//
//

import Foundation
import SQLite3

class Brave: BrowserModule {

    let braveDir: URL
    let writeFile: URL
    
    init(braveDir: URL, writeFile: URL) {
        self.braveDir = braveDir
        self.writeFile = writeFile
    }
    
    func getContents() {
        let username = getUsersOnSystem()
        let local_name = username[0].username
        
        let path = "/Users/\(local_name)/Library/Application Support/BraveSoftware/Brave-Browser/Default"
        let files = filemanager.filesInDirRecursive(path: path)
        
        for file in files {
            if file.lastPathComponent == "" {
                dumpHistory(file: file)
            }
        }
    }
    
    func dumpHistory(file: URL) {
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- Brave History -----\n")
        
        var db: OpaquePointer?
        if sqlite3_open(file.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "select datetime(vi.visit_time/1000000, 'unixepoch') as dt, urls.url FROM visits vi INNER join urls on vi.id = urls.id;"
            
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
                    
                    self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nURL: \(url)\n")
                }
            }
        }
        self.addTextToFile(atUrl: self.writeFile, text: "----- End of Brave History -----\n")
    }
    
    func dumpCookies() {
        let username = getUsersOnSystem()
        let local_name = username[0].username
        
        let file = URL(fileURLWithPath: "/Users/\(local_name)/Library/Application Support/BraveSoftware/Brave-Browser/Default/Cookies")
        
        self.addTextToFile(atUrl: self.writeFile, text: "----- Brave Cookies: -----\n")
        
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
                    
                    self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nName: \(name)\nHostKey: \(hostKey)\nPath:\(path)\nExpireTime: \(expireTime)\n\n")
                }
            }
        }
        
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- End of Brave Cookies -----\n")
    }
    
    override func run() {
        self.log("Collecting brave browser information...")
        getContents()
        dumpCookies()
    }
}
