//
//  Opera.swift
//  aftermath
//
//

import Foundation
import SQLite3

class Opera: BrowserModule {
        
    let operaDir: URL
    let writeFile: URL
    
    init(operaDir: URL, writeFile: URL) {
        self.operaDir = operaDir
        self.writeFile = writeFile
    }
    
    func gatherHistory() {
        let username = NSUserName()
        let file = URL(fileURLWithPath: "/Users/\(username)/Library/Application Support/Opera/com.operasoftware.Opera/History")
        
        self.addTextToFile(atUrl: self.writeFile, text: "----- Opera History: -----\n")
        
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
                    
                    self.addTextToFile(atUrl: self.writeFile, text: "DateTime: \(dateTime)\nURL: \(url)\nContent: \(currentPath)\n")
                }
            }
        }
        
        self.addTextToFile(atUrl: self.writeFile, text: "----- End of Opera Downloads -----")
    }
    
    override func run() {
        self.log("Collecting opera browser information...")
        gatherHistory()
    }
}
