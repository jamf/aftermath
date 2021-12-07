//
//  Safari.swift
//  aftermath
//
//

import Foundation
import SQLite3

class Safari {
        
    let caseHandler: CaseHandler
    let browserDir: URL
    let safariDir: URL
    let fm: FileManager
    let writeFile: URL
    let appPath: String
    
    init(caseHandler: CaseHandler, browserDir: URL, safariDir: URL, writeFile: URL, appPath: String) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.safariDir = safariDir
        self.fm = FileManager.default
        self.writeFile = writeFile
        self.appPath = appPath
    }
    
    func getHistory() {
        let username = NSUserName()
        let file = URL(fileURLWithPath: "/Users/\(username)/Library/Safari/History")
        
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "\n----- Safari History -----\n")
        
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
                    
                    self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nURL: \(url)\n")
                }
            }
        }
        
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "----- End of Safari History -----\n")
    }
    
    func dumpImportantPlists() {
        let username = NSUserName()
        let files: [URL] = [URL(fileURLWithPath: "/Users/\(username)/Library/Safari/Bookmarks.plist"), URL(fileURLWithPath: "/Users/\(username)/Library/Safari/Downloads.plist"), URL(fileURLWithPath: "/Users/\(username)/Library/Safari/UserNotificationPermissions.plist"), URL(fileURLWithPath: "/Users/\(username)/Library/Safari/LastSession.plist")]
        
        for file in files {
            let plistDict = Aftermath.getPlistAsDict(atUrl: file)
            self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "\nFile Name:\n----- \(file) -----\n\n\(plistDict.description)\n----- End of \(file) -----\n")
            
            self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.safariDir)
        }
    }
    
    func run() {
        self.caseHandler.log("Collecting safari browser information...")
        getHistory()
        dumpImportantPlists()
    }
}
