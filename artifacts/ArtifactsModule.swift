//
//  ArtifactsModule.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 11/29/21.
//

import Foundation
import SQLite3

class ArtifactsModule {
    
    let caseHandler: CaseHandler
    let artifactsDir: URL
    let tccDir: URL
    
    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        self.artifactsDir = caseHandler.createNewDir(dirName: "artifacts")
        self.tccDir = caseHandler.createNewDir(dirName: "artifacts/tcc_raw")
    }
    
    func getTCC() {
        self.caseHandler.log("Capturing TCC data...")
        let fileURL = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("com.apple.TCC/TCC.db")
        self.caseHandler.copyFileToCase(fileToCopy: fileURL, toLocation: tccDir)
        
        let capturedTCC = self.caseHandler.createNewCaseFile(dirUrl: self.artifactsDir, filename: "tccItems.txt")
        var db : OpaquePointer?
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "select client, auth_value, auth_reason from access"
            
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                var client: String = ""
                var authValue: String = ""
                var authReason: String = ""
                
                while sqlite3_step(queryStatement) == SQLITE_ROW {
                    let col1 = sqlite3_column_text(queryStatement, 0)
                    if col1 != nil{
                        client = String(cString: col1!)
                    }
                    
                    let col2 = sqlite3_column_text(queryStatement, 1)
                    if col2 != nil {
                        authValue = String(cString: col2!)
                        for item in TCCAuthValue.allCases {
                            if authValue == String(item.rawValue) {
                                authValue = String(describing: item)
                            }
                        }
                    }
                    
                    let col3 = sqlite3_column_text(queryStatement, 2)
                    if col3 != nil {
                        authReason = String(cString: col3!)
                        for item in TCCAuthReason.allCases {
                            if authReason == String(item.rawValue) {
                                authReason = String(describing: item)
                            }
                        }
                    }
                    
                    self.caseHandler.addTextToFile(atUrl: capturedTCC, text: "Name: \(client)\nAuth Value: \(authValue)\nAuth Reason: \(authReason)\n")
                }
            }
            self.caseHandler.log("Finished capturing TCC data")
        } else {
            self.caseHandler.log("An error occurred when attempting to query the TCC database...")
        }
    }
    
    func start() {
        getTCC()
    }
    
    enum TCCAuthValue: String, CaseIterable {
        case denied = "0"
        case unknown = "1"
        case allowed = "2"
        case limited = "3"
    }
    
    enum TCCAuthReason: String, CaseIterable {
        case error = "1"
        case userConsent = "2"
        case userSet = "3"
        case systemSet = "4"
        case servicePolicy = "5"
        case mdmPolicy = "6"
        case overridePolicy = "7"
        case missingUsageString = "8"
        case promptTimeout = "9"
        case preflightUnknown = "10"
        case entitled = "11"
        case appTypePolicy = "12"
    }
}
