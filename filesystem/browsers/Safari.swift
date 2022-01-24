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
        let username = NSUserName()
        let file = URL(fileURLWithPath: "/Users/\(username)/Library/Safari/History")
        
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
        
        self.addTextToFile(atUrl: self.writeFile, text: "----- End of Safari History -----\n")
    }
    
    func dumpImportantPlists() {
        let username = NSUserName()
        let files: [URL] = [URL(fileURLWithPath: "/Users/\(username)/Library/Safari/Bookmarks.plist"), URL(fileURLWithPath: "/Users/\(username)/Library/Safari/Downloads.plist"), URL(fileURLWithPath: "/Users/\(username)/Library/Safari/UserNotificationPermissions.plist"), URL(fileURLWithPath: "/Users/\(username)/Library/Safari/LastSession.plist")]
        
        for file in files {
            let plistDict = Aftermath.getPlistAsDict(atUrl: file)
            self.addTextToFile(atUrl: self.writeFile, text: "\nFile Name:\n----- \(file) -----\n\n\(plistDict.description)\n----- End of \(file) -----\n")
            
            self.copyFileToCase(fileToCopy: file, toLocation: self.safariDir)
        }
    }
    
    override func run() {
        self.log("Collecting safari browser information...")
        getHistory()
        dumpImportantPlists()
    }
}
