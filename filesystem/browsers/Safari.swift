//
//  Safari.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation
import SQLite3

class Safari: BrowserModule {
        
    let safariDir: URL
    let writeFile: URL
    
    init(safariDir: URL, writeFile: URL) {
        self.safariDir = safariDir
        self.writeFile = writeFile
    }
    
    func getHistory() {
        
        let historyOutput = self.createNewCaseFile(dirUrl: self.safariDir, filename: "history_output.csv")
        self.addTextToFile(atUrl: historyOutput, text: "timestamp,url")
        
        for user in getBasicUsersOnSystem() {
            
            
            var file: URL
            if filemanager.fileExists(atPath: "\(user.homedir)/Library/Safari/History.db") {
                file = URL(fileURLWithPath: "\(user.homedir)/Library/Safari/History.db")
                self.copyFileToCase(fileToCopy: file, toLocation: self.safariDir, newFileName: "history_\(user.username)")
            } else { continue }
            
            var db: OpaquePointer?
            if sqlite3_open(file.path, &db) == SQLITE_OK {
                var queryStatement: OpaquePointer? = nil
                let queryString = "SELECT h.visit_time, i.url FROM history_visits h INNER JOIN history_items i ON h.history_item = i.id;"
                
                if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                    var dateTime: String = ""
                    var url: String = ""
                    
                    while sqlite3_step(queryStatement) == SQLITE_ROW {
                        let col1  = sqlite3_column_text(queryStatement, 0)
                        if let col1 = col1 { dateTime = Aftermath.dateFromEpochTimestamp(timeStamp: (String(cString: col1) as NSString).doubleValue + 978307200) }
                        
                        let col2 = sqlite3_column_text(queryStatement, 1)
                        if let col2 = col2 { url = String(cString: col2) }
                        
                        self.addTextToFile(atUrl: historyOutput, text: "\(dateTime),\(url)")
                    }
                }
            }
        }
    }
    
    func dumpImportantPlists() {
        let notificationsCsv = self.createNewCaseFile(dirUrl: self.safariDir, filename: "safari_notifications.csv")
        self.addTextToFile(atUrl: notificationsCsv, text: "date_added, url, permission")
        
        self.addTextToFile(atUrl: self.writeFile, text: "\n-----Safari Bookmarks, Downlaods, UserNotificationPermissions, LastSession-----\n\n")
        for user in getBasicUsersOnSystem() {

            let files: [URL] = [URL(fileURLWithPath: "\(user.homedir)/Library/Safari/Bookmarks.plist"), URL(fileURLWithPath: "\(user.homedir)/Library/Safari/LastSession.plist")]
            
            for file in files {
                if filemanager.fileExists(atPath: file.path) {
                    let plistDict = Aftermath.getPlistAsDict(atUrl: file)
                    self.addTextToFile(atUrl: self.writeFile, text: "\nFile Name:\n----- \(file) -----\n\n\(plistDict.description)\n----- End of \(file) -----\n")
                    
                    self.copyFileToCase(fileToCopy: file, toLocation: self.safariDir)
                }
            }
            
            let notificationsPlistPath = URL(fileURLWithPath: "\(user.homedir)/Library/Safari/UserNotificationPermissions.plist")
            if filemanager.fileExists(atPath: notificationsPlistPath.path) {
                let plistDict = Aftermath.getPlistAsDict(atUrl: notificationsPlistPath)
                self.copyFileToCase(fileToCopy: notificationsPlistPath, toLocation: self.safariDir)
                
                for (key, value) in plistDict {
                    let url = key
                    var permissions = "unknown"
                    var timestamp = "unknown"
                    for i in (value as! NSDictionary) {
            
                        if String(describing: i.key) == "Date Added" {
                            let unformatted = String(describing: i.value) // 2022-10-25 19:18:22 +0000
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.locale = Locale(identifier: "en_US")
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                            
                            guard let formatted = dateFormatter.date(from: unformatted) else { continue }
                            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                            let dateString = dateFormatter.string(from: formatted)
                           
                            timestamp = dateString
                        }
                        
                        if String(describing: i.key) == "Permission" {
                            permissions = String(describing: i.value)
                        }
                       
                    }
                    self.addTextToFile(atUrl: notificationsCsv, text: "\(timestamp), \(url), \(permissions)")
                }
            }
        }
    }
    
    func dumpDownloads() {
        
        let safariDownloads = self.createNewCaseFile(dirUrl: self.safariDir, filename: "downloads_output.csv")
        self.addTextToFile(atUrl: safariDownloads, text: "timestamp,url")
        
        for user in getBasicUsersOnSystem() {
            let downloadsPlist = URL(fileURLWithPath: "\(user.homedir)/Library/Safari/Downloads.plist")
                
            if filemanager.fileExists(atPath: downloadsPlist.path) {
                let plistDict = Aftermath.getPlistAsDict(atUrl: downloadsPlist)
                
                var timestamp: String = "unknown"
                var url: String = "unknown"
                for (_ ,value) in plistDict {
                    for i in (value as! NSArray) {

                        let valuePlist = i as! NSDictionary
                        
                        for (key,value) in valuePlist {
                            if key as! String == "DownloadEntryDateFinishedKey" {
                                let dateTimestamp = value as! Date
                                let dateFormatter = DateFormatter()
                                dateFormatter.locale = Locale(identifier: "en_US")
                                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

                                let dateString = dateFormatter.string(from: dateTimestamp as Date)
                                timestamp = dateString
                            }
                            if key as! String == "DownloadEntryURL" {
                                url = value as! String
                            }
                        }
                        self.addTextToFile(atUrl: safariDownloads, text: "\(timestamp),\(url)")
                    }
                }
            }
        }
    }
    
    override func run() {
        self.log("Collecting Safari browser information...")
        getHistory()
        dumpImportantPlists()
        dumpDownloads()
    }
}

