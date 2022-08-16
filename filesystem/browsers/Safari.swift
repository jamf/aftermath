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
        self.addTextToFile(atUrl: historyOutput, text: "datetime,url")
        
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
        self.addTextToFile(atUrl: self.writeFile, text: "\n-----Safari Bookmarks, Downlaods, UserNotificationPermissions, LastSession-----\n\n")
        for user in getBasicUsersOnSystem() {

            let files: [URL] = [URL(fileURLWithPath: "\(user.homedir)/Library/Safari/Bookmarks.plist"), URL(fileURLWithPath: "\(user.homedir)/Library/Safari/UserNotificationPermissions.plist"), URL(fileURLWithPath: "\(user.homedir)/Library/Safari/LastSession.plist")]
            
            for file in files {
                if filemanager.fileExists(atPath: file.path) {
                    let plistDict = Aftermath.getPlistAsDict(atUrl: file)
                    self.addTextToFile(atUrl: self.writeFile, text: "\nFile Name:\n----- \(file) -----\n\n\(plistDict.description)\n----- End of \(file) -----\n")
                    
                    self.copyFileToCase(fileToCopy: file, toLocation: self.safariDir)
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
                for (key,value) in plistDict {
                    print("in the for loop")
                    print(type(of: value))
                    print(value)
                    
                    for i in (value as! NSArray) {
                        print("next")
                        print(type(of: i))
                        print(i)
                    }
//                    if value == "DownloadEntryDateFinishedKey" {
//                        timestamp = String(describing: value.value)
//                    }
//                    if value.key == "DownloadEntryURL" {
//                        url = String(describing: value.value)
//                    }
                    self.addTextToFile(atUrl: safariDownloads, text: "\(timestamp),\(url)")
//                    print("Time: \(timestamp)\nURL:\(url)\n\n")
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

