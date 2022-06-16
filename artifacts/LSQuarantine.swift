//
//  LSQuarantine.swift
//  aftermath
//
//

import Foundation
import SQLite3


class LSQuarantine: ArtifactsModule {
    

    let rawDir: URL
    
    init(rawDir: URL) {
        self.rawDir = rawDir
    }
    
    func getLSQuarantine() {
        self.log("Capturing LSQuarantine data...")
 
        var fileURL: URL
        for user in getBasicUsersOnSystem() {
            if (user.username == "root") { continue }
            
            fileURL = URL(fileURLWithPath: "\(user.homedir)/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2")
            self.copyFileToCase(fileToCopy: fileURL, toLocation: self.rawDir, newFileName: "lsquarantine_\(user.username)")

            let parsedLSQuarantine = self.createNewCaseFile(dirUrl: self.moduleDirRoot, filename: "lsQuarantine.txt")
            
            var db : OpaquePointer?
            
            if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
                var queryStatement: OpaquePointer? = nil
                let queryString = "select LSQuarantineTimeStamp, LSQuarantineAgentName, LSQuarantineAgentBundleIdentifier, LSQuarantineDataURLString, LSQuarantineOriginURLString, LSQuarantineSenderName, LSQuarantineSenderAddress from LSQuarantineEvent order by LSQuarantineTimeStamp desc"
                
                if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                    var LSQuarantineTimeStamp: String = ""
                    var LSQuarantineAgentName: String = ""
                    var LSQuarantineAgentBundleIdentifier: String = ""
                    var LSQuarantineDataURLString: String = ""
                    var LSQuarantineOriginURLString: String = ""
                    var LSQuarantineSenderName: String = ""
                    var LSQuarantineSenderAddress: String = ""
                    
                    while sqlite3_step(queryStatement) == SQLITE_ROW {
                        if let col1 = sqlite3_column_text(queryStatement, 0) {
                            let timestamp = (String(cString: col1) as NSString).doubleValue
                            LSQuarantineTimeStamp = Aftermath.dateFromTimestamp(timeStamp: timestamp + 978307200)
                        }
                        
                        if let col2 = sqlite3_column_text(queryStatement, 1) {
                            LSQuarantineAgentName = String(cString: col2)
                        }
                        
                        if let col3 = sqlite3_column_text(queryStatement, 2) {
                            LSQuarantineAgentBundleIdentifier = String(cString: col3)
                        }
                        
                        if let col4 = sqlite3_column_text(queryStatement, 3) {
                            LSQuarantineDataURLString = String(cString: col4)
                        }
                        
                        if let col5 = sqlite3_column_text(queryStatement, 4) {
                            LSQuarantineOriginURLString = String(cString: col5)
                        }
                        
                        if let col6 = sqlite3_column_text(queryStatement, 5) {
                            LSQuarantineSenderName = String(cString: col6)
                        }
                        
                        if let col7 = sqlite3_column_text(queryStatement, 6) {
                            LSQuarantineSenderAddress = String(cString: col7)
                        }
                        
                        self.addTextToFile(atUrl: parsedLSQuarantine, text: "Timestamp: \(LSQuarantineTimeStamp)\nAgent Name: \(LSQuarantineAgentName)\nAgent Identifier: \(LSQuarantineAgentBundleIdentifier)\nDownload URL: \(LSQuarantineDataURLString)\nOrigin URL: \(LSQuarantineOriginURLString)\nSender Name: \(LSQuarantineSenderName)\nSender Address: \(LSQuarantineSenderAddress)\n")
                    }
                }
            self.log("Finished capturing LSQuarantine data")
            } else {
                self.log("An error occurred when attempting to query the LSQuarantine database...")
            }
        }
    }
    
    override func run() {
        self.log("Capturing LSQuarantine data...")
        getLSQuarantine()
    }
}

