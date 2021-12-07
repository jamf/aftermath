//
//  Opera.swift
//  aftermath
//
//

import Foundation
import SQLite3

class Opera {
        
    let caseHandler: CaseHandler
    let browserDir: URL
    let operaDir: URL
    let fm: FileManager
    let writeFile: URL
    let appPath: String
    
    init(caseHandler: CaseHandler, browserDir: URL, operaDir: URL, writeFile: URL, appPath: String) {
        self.caseHandler = caseHandler
        self.browserDir = browserDir
        self.operaDir = operaDir
        self.fm = FileManager.default
        self.writeFile = writeFile
        self.appPath = appPath
    }
    
    func gatherHistory() {
        let username = NSUserName()
        let file = URL(fileURLWithPath: "/Users/\(username)/Library/Application Support/Opera/com.operasoftware.Opera/History")
        
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "----- Opera History: -----\n")
        
        var db: OpaquePointer?
        if sqlite3_open(file.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "SELECT start_time, current_path FROM downloads;"
        
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                var dateTime: String = ""
                var currentPath: String = ""
                var url: String = ""
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let col1  = sqlite3_column_text(queryStatement, 0)
                    if col1 != nil {
                        dateTime = String(cString: col1!)
                    }
                    
                    let col2 = sqlite3_column_text(queryStatement, 1)
                    if col2 != nil {
                        currentPath = String(cString: col2!)
                    }
                    
                    let col3 = sqlite3_column_text(queryStatement, 2)
                    if col3 != nil {
                        url = String(cString: col3!)
                    }
                    
                    self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nURL: \(url)\nContent: \(currentPath)\n")
                    print(url)
                }
            }
        }
        
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "----- End of Opera Downloads -----")
    }
    
    func run() {
        // Check if Opera is installed
        if !aftermath.systemReconModule.installAppsArray.contains(appPath) {
            self.caseHandler.log("Opera not installed. Continuing browser recon...")
            return
        }
        
        self.caseHandler.log("Collecting opera browser information...")
        gatherHistory()
    }
}
