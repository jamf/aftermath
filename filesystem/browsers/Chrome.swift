//
//  Chrome.swift
//  aftermath
//
//

import Foundation
import SQLite3

class Chrome: BrowserModule {
        
    let chromeDir: URL
    let fm: FileManager
    let writeFile: URL
    
    init(chromeDir: URL, writeFile: URL) {
        self.chromeDir = chromeDir
        self.fm = FileManager.default
        self.writeFile = writeFile
    }
    
    func gatherHistory() {
        let username = NSUserName()
        let file = URL(fileURLWithPath: "/Users/\(username)/Library/Application Support/Google/Chrome/Default/History")
        
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- Chrome History: -----\n")
        
        var db: OpaquePointer?
        if sqlite3_open(file.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "SELECT datetime(((v.visit_time/1000000)-11644473600), 'unixepoch'), u.url FROM visits v INNER JOIN urls u ON u.id = v.url;"
        
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
                    
                    self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nURL: \(url)\n\n")
                }
            }
        }
        
        self.addTextToFile(atUrl: self.writeFile, text: "----- End of Chrome History -----\n")
    }
    
    func dumpDownloads() {
        let username = NSUserName()
        let file = URL(fileURLWithPath: "/Users/\(username)/Library/Application Support/Google/Chrome/Default/History")
        
        self.addTextToFile(atUrl: self.writeFile, text: "----- Chrome Downloads: -----\n")
        
        var db: OpaquePointer?
        if sqlite3_open(file.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "SELECT datetime(d.start_time/1000000-11644473600, 'unixepoch'), dc.url, d.target_path, d.danger_type, d.opened FROM downloads d INNER JOIN downloads_url_chains dc ON dc.id = d.id;"
        
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                var dateTime: String = ""
                var url: String = ""
                var targetPath: String = ""
                var dangerType: String = ""
                var opened: String = ""
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let col1  = sqlite3_column_text(queryStatement, 0)
                    if col1 != nil {
                        dateTime = String(cString: col1!)
                    }
                    
                    let col2 = sqlite3_column_text(queryStatement, 1)
                    if col2 != nil {
                        url = String(cString: col2!)
                    }
                    
                    let col3 = sqlite3_column_text(queryStatement, 2)
                    if col3 != nil {
                        targetPath = String(cString: col1!)
                    }
                    
                    let col4 = sqlite3_column_text(queryStatement, 3)
                    if col4 != nil {
                        dangerType = String(cString: col2!)
                    }
                    
                    let col5 = sqlite3_column_text(queryStatement, 4)
                    if col5 != nil {
                        opened = String(cString: col1!)
                    }
                    
                    self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nURL: \(url)\nTargetPath: \(targetPath)\nDangerType:\(dangerType)\nOpened: \(opened)\n\n")
                }
            }
        }
        
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- End of Chrome Downlaods -----\n")
    }
    
    // TODO - this needs to be tuned more
    func captureExtensions() {
        let username = NSUserName()
        let exdir = "/Users/\(username)/Library/Application Support/Google/Chrome/Default/Extensions"
        let _ = fm.filesInDirRecursive(path: exdir)
//
//        for file in files {
//            self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.chromeDir)
//        }
    }
    
    func dumpPreferences() {
        let username = NSUserName()
        let file = URL(fileURLWithPath: "/Users/\(username)/Library/Application Support/Google/Chrome/Default/Preferences")
                
        do {
            let data = try Data(contentsOf: file, options: .mappedIfSafe)
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] {
                self.addTextToFile(atUrl: writeFile, text: "\nChrome Preferences -----\n\(String(describing: json))\n ----- End of Chrome Preferences -----\n")
            }
            
        } catch { self.log("Unable to capture Chrome Preferenes") }
    }
    
    func dumpCookies() {
        let username = NSUserName()
        let file = URL(fileURLWithPath: "/Users/\(username)/Library/Application Support/Google/Chrome/Default/Cookies")
        
        self.addTextToFile(atUrl: self.writeFile, text: "----- Chrome Cookies: -----\n")
        
        var db: OpaquePointer?
        if sqlite3_open(file.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "select datetime(creation_utc/100000 -11644473600, 'unixepoch'), name,  host_key, path, datetime(expires_utc/100000-11644473600, 'unixepoch') from cookies;"
        
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
        
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- End of Chrome Cookies -----\n")
    }
    
    override func run() {
        self.log("Collecting chrome browser information...")
        gatherHistory()
        dumpDownloads()
        captureExtensions()
        dumpPreferences()
        dumpCookies()
    }
}
