//
//  Chrome.swift
//  aftermath
//
//

import Foundation
import SQLite3

class Chrome: BrowserModule {
        
    let chromeDir: URL
    let writeFile: URL
    
    init(chromeDir: URL, writeFile: URL) {
        self.chromeDir = chromeDir
        self.writeFile = writeFile
    }
    
    func gatherHistory() {

        let historyOutput = self.createNewCaseFile(dirUrl: self.chromeDir, filename: "history_output.csv")
        self.addTextToFile(atUrl: historyOutput, text: "datetime,url")
        
        for user in getBasicUsersOnSystem() {
            
            
            
            var file: URL
            if filemanager.fileExists(atPath: "\(user.homedir)/Library/Application Support/Google/Chrome/Default/History") {
                file = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/Google/Chrome/Default/History")
                self.copyFileToCase(fileToCopy: file, toLocation: self.chromeDir, newFileName: "history_and_downloads\(user.username)")
            } else { continue }
            
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
                        
                        self.addTextToFile(atUrl: historyOutput, text: "\(dateTime),\(url)")
                    }
                }
            }
        }
    }
    
    func dumpDownloads() {
        self.addTextToFile(atUrl: self.writeFile, text: "----- Chrome Downloads: -----\n")
        
        let downlaodsRaw = self.createNewCaseFile(dirUrl: self.chromeDir, filename: "downloads_output.csv")
        self.addTextToFile(atUrl: downlaodsRaw, text: "datetime,url,target_path,danger_type,opened")
        
        for user in getBasicUsersOnSystem() {
            var file: URL
            if filemanager.fileExists(atPath: "\(user.homedir)/Library/Application Support/Google/Chrome/Default/History") {
                file = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/Google/Chrome/Default/History")
            } else { continue }
            
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
                        if let col1 = col1 { dateTime = String(cString: col1) }
                        
                        let col2 = sqlite3_column_text(queryStatement, 1)
                        if let col2 = col2 { url = String(cString: col2) }

                        let col3 = sqlite3_column_text(queryStatement, 2)
                        if let col3 = col3 { targetPath = String(cString: col3) }
                        
                        let col4 = sqlite3_column_text(queryStatement, 3)
                        if let col4 = col4 { dangerType = String(cString: col4) }
                        
                        let col5 = sqlite3_column_text(queryStatement, 4)
                        if let col5 = col5 { opened = String(cString: col5) }
                        
                        self.addTextToFile(atUrl: downlaodsRaw, text: " \(dateTime), \(url), \(targetPath),\(dangerType), \(opened)")
                    }
                }
            }
        }
        
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- End of Chrome Downlaods -----\n")
    }
    
    func dumpPreferences() {
        for user in getBasicUsersOnSystem() {
            var file: URL
            if filemanager.fileExists(atPath: "\(user.homedir)/Library/Application Support/Google/Chrome/Default/Preferences") {
                file = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/Google/Chrome/Default/Preferences")
                self.copyFileToCase(fileToCopy: file, toLocation: self.chromeDir, newFileName: "preferenes_\(user.username)")
            } else { continue }
                    
            do {
                let data = try Data(contentsOf: file, options: .mappedIfSafe)
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] {
                    self.addTextToFile(atUrl: writeFile, text: "\nChrome Preferences -----\n\(String(describing: json))\n ----- End of Chrome Preferences -----\n")
                }
                
            } catch { self.log("Unable to capture Chrome Preferenes") }
        }
    }
    
    func dumpCookies() {
        self.addTextToFile(atUrl: self.writeFile, text: "----- Chrome Cookies: -----\n")

        for user in getBasicUsersOnSystem() {
            var file: URL
            if filemanager.fileExists(atPath: "\(user.homedir)/Library/Application Support/Google/Chrome/Default/Cookies") {
                file = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/Google/Chrome/Default/Cookies")
                self.copyFileToCase(fileToCopy: file, toLocation: self.chromeDir, newFileName: "cookies_\(user.username)")
            } else { continue }
                        
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
                        if let col1  = sqlite3_column_text(queryStatement, 0) {
                            dateTime = String(cString: col1)
                        }
                        
                        if let col2 = sqlite3_column_text(queryStatement, 1) {
                            name = String(cString: col2)
                        }
                        
                        if let col3 = sqlite3_column_text(queryStatement, 2) {
                            hostKey = String(cString: col3)
                        }
                        
                        if let col4 = sqlite3_column_text(queryStatement, 3) {
                            path = String(cString: col4)
                        }
                        
                        if let col5 = sqlite3_column_text(queryStatement, 4) {
                            expireTime = String(cString: col5)
                        }
                        
                        self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nName: \(name)\nHostKey: \(hostKey)\nPath:\(path)\nExpireTime: \(expireTime)\n\n")
                    }
                }
            }
        }
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- End of Chrome Cookies -----\n")
    }
    
    override func run() {
        self.log("Collecting Chrome browser information...")
        gatherHistory()
        dumpDownloads()
        dumpPreferences()
        dumpCookies()
    }
}
