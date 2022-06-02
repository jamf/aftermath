//
//  LSQuarantine.swift
//  aftermath
//
//

import Foundation
import SQLite3


class LSQuarantine: ArtifactsModule {
    

    func getLSQuarantine() {
        self.log("Capturing LSQuarantine data...")
 
        var fileURL: URL
        for user in getBasicUsersOnSystem() {
            if (user.username == "root") { continue }
            fileURL = URL(fileURLWithPath: "\(user.homedir)/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2")
        

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
                        let col1 = sqlite3_column_text(queryStatement, 0)
                        if col1 != nil {
                            let timestamp = (String(cString: col1!) as NSString).doubleValue
                            LSQuarantineTimeStamp = Aftermath.dateFromTimestamp(timeStamp: timestamp + 978307200)
                        }
                        
                        let col2 = sqlite3_column_text(queryStatement, 1)
                        if col2 != nil {
                            LSQuarantineAgentName = String(cString: col2!)
                        }
                        
                        let col3 = sqlite3_column_text(queryStatement, 2)
                        if col3 != nil {
                            LSQuarantineAgentBundleIdentifier = String(cString: col3!)
                        }
                        
                        let col4 = sqlite3_column_text(queryStatement, 3)
                        if col4 != nil {
                            LSQuarantineDataURLString = String(cString: col4!)
                        }
                        
                        let col5 = sqlite3_column_text(queryStatement, 4)
                        if col5 != nil {
                            LSQuarantineOriginURLString = String(cString: col5!)
                        }
                        
                        let col6 = sqlite3_column_text(queryStatement, 5)
                        if col6 != nil {
                            LSQuarantineSenderName = String(cString: col6!)
                        }
                        
                        let col7 = sqlite3_column_text(queryStatement, 6)
                        if col7 != nil {
                            LSQuarantineSenderAddress = String(cString: col7!)
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
        getLSQuarantine()
    }
}

