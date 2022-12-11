//
//  Edge.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation
import SQLite3

class Edge: BrowserModule {
        
    let edgeDir: URL
    let writeFile: URL
    
    init(edgeDir: URL, writeFile: URL) {
        self.edgeDir = edgeDir
        self.writeFile = writeFile
    }
    
    func gatherHistory() {

        let historyOutput = self.createNewCaseFile(dirUrl: self.edgeDir, filename: "history_output.csv")
        self.addTextToFile(atUrl: historyOutput, text: "datetime,user,profile,url")
        
        for user in getBasicUsersOnSystem() {
            for profile in getEdgeProfilesForUser(user: user) {

                // Get the history file for the profile
                var file: URL
                if filemanager.fileExists(atPath: "\(user.homedir)/Library/Application Support/Microsoft Edge/\(profile)/History") {
                    file = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/Microsoft Edge/\(profile)/History")
                    self.copyFileToCase(fileToCopy: file, toLocation: self.edgeDir, newFileName: "history_and_downloads_\(user.username)_\(profile).db")
                } else { continue }

                // Open the history file
                var db: OpaquePointer?
                if sqlite3_open(file.path, &db) == SQLITE_OK {
                
                    // Query the history file
                    var queryStatement: OpaquePointer? = nil
                    let queryString = "SELECT datetime(((v.visit_time/1000000)-11644473600), 'unixepoch'), u.url FROM visits v INNER JOIN urls u ON u.id = v.url;"

                    if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                        var dateTime: String = ""
                        var url: String = ""
                        
                        // write the results to the historyOutput file
                        while sqlite3_step(queryStatement) == SQLITE_ROW {
                            if let col1  = sqlite3_column_text(queryStatement, 0) {
                                let unformattedDatetime = String(cString: col1)
                                dateTime = Aftermath.standardizeMetadataTimestamp(timeStamp: unformattedDatetime)
                            }
                            
                            let col2 = sqlite3_column_text(queryStatement, 1)
                            if col2 != nil {
                                url = String(cString: col2!)
                            }
                            
                            self.addTextToFile(atUrl: historyOutput, text: "\(dateTime),\(user.username),\(profile),\(url)")
                        }
                    } else { self.log("Unable to query the database. Please ensure that Edge is not running.") }
                } else { self.log("Unable to open the database") }
            }
        }
    }
    
    func dumpDownloads() {
        self.addTextToFile(atUrl: self.writeFile, text: "----- Edge Downloads: -----\n")
        
        let downlaodsRaw = self.createNewCaseFile(dirUrl: self.edgeDir, filename: "downloads_output.csv")
        self.addTextToFile(atUrl: downlaodsRaw, text: "datetime,user,profile,url,target_path,danger_type,opened")
        
        for user in getBasicUsersOnSystem() {
            for profile in getEdgeProfilesForUser(user: user) {
                var file: URL
                if filemanager.fileExists(atPath: "\(user.homedir)/Library/Application Support/Microsoft Edge/\(profile)/History") {
                    file = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/Microsoft Edge/\(profile)/History")
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
                            if let col1  = sqlite3_column_text(queryStatement, 0) {
                                let unformattedDatetime = String(cString: col1)
                                dateTime = Aftermath.standardizeMetadataTimestamp(timeStamp: unformattedDatetime)
                            }
                            
                            let col2 = sqlite3_column_text(queryStatement, 1)
                            if let col2 = col2 { url = String(cString: col2) }

                            let col3 = sqlite3_column_text(queryStatement, 2)
                            if let col3 = col3 { targetPath = String(cString: col3) }
                            
                            let col4 = sqlite3_column_text(queryStatement, 3)
                            if let col4 = col4 { dangerType = String(cString: col4) }
                            
                            let col5 = sqlite3_column_text(queryStatement, 4)
                            if let col5 = col5 { opened = String(cString: col5) }
                            
                            self.addTextToFile(atUrl: downlaodsRaw, text: " \(dateTime),\(user.username),\(profile),\(url),\(targetPath),\(dangerType),\(opened)")
                        }
                    }
                }
            }
        }
        
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- End of Edge Downloads -----\n")
    }
    
    func dumpPreferences() {
        for user in getBasicUsersOnSystem() {
            for profile in getEdgeProfilesForUser(user: user) {
                var file: URL
                if filemanager.fileExists(atPath: "\(user.homedir)/Library/Application Support/Microsoft Edge/\(profile)/Preferences") {
                    file = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/Microsoft Edge/\(profile)/Preferences")
                    self.copyFileToCase(fileToCopy: file, toLocation: self.edgeDir, newFileName: "preferences_\(user.username)_\(profile)")
                } else { continue }
                        
                do {
                    let data = try Data(contentsOf: file, options: .mappedIfSafe)
                    if let json = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [String: Any] {
                        self.addTextToFile(atUrl: writeFile, text: "\nEdge Preferences -----\n\(String(describing: json))\n ----- End of Edge Preferences -----\n")
                    }
                    
                } catch { self.log("Unable to capture Edge Preferenes") }
            }
        }
    }
    
    func dumpCookies() {
        self.addTextToFile(atUrl: self.writeFile, text: "----- Edge Cookies: -----\n")

        for user in getBasicUsersOnSystem() {
            for profile in getEdgeProfilesForUser(user: user) {
                var file: URL
                if filemanager.fileExists(atPath: "\(user.homedir)/Library/Application Support/Microsoft Edge/\(profile)/Cookies") {
                    file = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/Microsoft Edge/\(profile)/Cookies")
                    self.copyFileToCase(fileToCopy: file, toLocation: self.edgeDir, newFileName: "cookies_\(user.username)_\(profile).db")
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
                            
                            self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nUser: \(user.username)\nProfile: \(profile)\nName: \(name)\nHostKey: \(hostKey)\nPath:\(path)\nExpireTime: \(expireTime)\n\n")
                        }
                    }
                }
            }
        }
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- End of Edge Cookies -----\n")
    }
    
    func captureExtensions() {
        for user in getBasicUsersOnSystem() {
            for profile in getEdgeProfilesForUser(user: user) {
                let edgeExtensionDir = self.createNewDir(dir: self.edgeDir, dirname: "extensions_\(user.username)_\(profile)")
                let path = "\(user.homedir)/Library/Application Support/Microsoft Edge/\(profile)/Extensions"
            
                for file in filemanager.filesInDirRecursive(path: path) {
                    self.copyFileToCase(fileToCopy: file, toLocation: edgeExtensionDir)
                }
            }
            
        }
    }

    func getEdgeProfilesForUser(user: User) -> [String] {
        var profiles: [String] = []
        // Get the directory name if it contains the string "Profile"
        if filemanager.fileExists(atPath: "\(user.homedir)/Library/Application Support/Microsoft Edge") {
            for file in filemanager.filesInDir(path: "\(user.homedir)/Library/Application Support/Microsoft Edge") {
                if file.lastPathComponent.starts(with: "Profile") || file.lastPathComponent == "Default" {
                    profiles.append(file.lastPathComponent)
                }
            }
        }
        
        return profiles
    }
    
    override func run() {
        self.log("Collecting Edge browser information...")
        gatherHistory()
        dumpDownloads()
        dumpPreferences()
        dumpCookies()
        captureExtensions()
    }
}
