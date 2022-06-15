//
//  Safari.swift
//  aftermath
//
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
        
        for user in getBasicUsersOnSystem() {
            var file: URL
            if filemanager.fileExists(atPath: "\(user.homedir)/Library/Safari/History.db") {
                file = URL(fileURLWithPath: "\(user.homedir)/Library/Safari/History.db")
                self.copyFileToCase(fileToCopy: file, toLocation: self.safariDir, newFileName: "history_\(user.username)")
            } else { continue }
            
            
            
            self.addTextToFile(atUrl: self.writeFile, text: "\n----- Safari History -----\n")
            
            var db: OpaquePointer?
            if sqlite3_open(file.path, &db) == SQLITE_OK {
                var queryStatement: OpaquePointer? = nil
                let queryString = "SELECT h.visit_time, i.url FROM history_visits h INNER JOIN history_items i ON h.history_item = i.id;"
                
                if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                    var dateTime: String = ""
                    var url: String = ""
                    
                    while sqlite3_step(queryStatement) == SQLITE_ROW {
                        let col1  = sqlite3_column_text(queryStatement, 0)
                        if let col1 = col1 { dateTime = String(cString: col1) }
                        
                        let col2 = sqlite3_column_text(queryStatement, 1)
                        if let col2 = col2 { url = String(cString: col2) }
                        
                        self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nURL: \(url)\n")
                    }
                }
            }
            
            self.addTextToFile(atUrl: self.writeFile, text: "----- End of Safari History -----\n")
        }
    }
    
    func dumpImportantPlists() {
        self.addTextToFile(atUrl: self.writeFile, text: "\n-----Safari Bookmarks, Downlaods, UserNotificationPermissions, LastSession-----\n\n")
        for user in getBasicUsersOnSystem() {

            let files: [URL] = [URL(fileURLWithPath: "\(user.homedir)/Library/Safari/Bookmarks.plist"), URL(fileURLWithPath: "\(user.homedir)/Library/Safari/Downloads.plist"), URL(fileURLWithPath: "\(user.homedir)/Library/Safari/UserNotificationPermissions.plist"), URL(fileURLWithPath: "\(user.homedir)/Library/Safari/LastSession.plist")]
            
            for file in files {
                if filemanager.fileExists(atPath: file.path) {
                    let plistDict = Aftermath.getPlistAsDict(atUrl: file)
                    self.addTextToFile(atUrl: self.writeFile, text: "\nFile Name:\n----- \(file) -----\n\n\(plistDict.description)\n----- End of \(file) -----\n")
                    
                    self.copyFileToCase(fileToCopy: file, toLocation: self.safariDir)
                }
            }
        }
    }
    
    override func run() {
        self.log("Collecting Safari browser information...")
        getHistory()
        dumpImportantPlists()
    }
}

