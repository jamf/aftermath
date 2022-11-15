//
//  Parser.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation
import SQLite3


class DatabaseParser: AftermathModule {
    
    lazy var tccWriteFile = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "tcc.csv")
    lazy var quarantineWriteFile = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "lsquarantine.csv")
    let collectionDir: String
    let storylineFile: URL
 
    init(collectionDir: String, storylineFile: URL) {
        self.collectionDir = collectionDir
        self.storylineFile = storylineFile
    }
    
    func parseTCC() {
        self.addTextToFile(atUrl: tccWriteFile, text: "name, service, auth_value, auth_reason, last_modified")

        let rawDir = "\(self.collectionDir)/Artifacts/raw/"
        var tccFiles = [URL]()
        for f in filemanager.filesInDir(path: rawDir) {
            if f.lastPathComponent.contains("tcc") {
                tccFiles.append(f)
            }
        }
        
        for tcc_path in tccFiles {
            
            var db : OpaquePointer?
            
            if sqlite3_open(tcc_path.path, &db) == SQLITE_OK {
                var queryStatement: OpaquePointer? = nil
                let queryString = "select client, auth_value, auth_reason, service, last_modified from access order by last_modified desc"
                
                if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                    var client: String = ""
                    var authValue: String = ""
                    var authReason: String = ""
                    var service: String = ""
                    var last_modified: String = ""
                    
                    while sqlite3_step(queryStatement) == SQLITE_ROW {
                        
                        let col1 = sqlite3_column_text(queryStatement, 0)
                        if let col1 = col1 { client = String(cString: col1) }
                        
                        let col2 = sqlite3_column_text(queryStatement, 1)
                        if let col2 = col2 {
                            authValue = String(cString: col2)
                            for item in TCCAuthValue.allCases {
                                if authValue == String(item.rawValue) {
                                    authValue = String(describing: item)
                                }
                            }
                        }
                        
                        let col3 = sqlite3_column_text(queryStatement, 2)
                        if let col3 = col3 {
                            authReason = String(cString: col3)
                            for item in TCCAuthReason.allCases {
                                if authReason == String(item.rawValue) {
                                    authReason = String(describing: item)
                                }
                            }
                        }
                        
                        let col4 = sqlite3_column_text(queryStatement, 3)
                        if let col4 = col4 {
                            service = String(cString: col4)
                            for item in TCCService.allCases {
                                if service == String(item.rawValue) {
                                    service = String(describing: item)
                                }
                            }
                        }
                        
                        // in epoch time
                        let col5 = sqlite3_column_text(queryStatement, 4)
                        if let col5 = col5 {
                            last_modified = Aftermath.dateFromEpochTimestamp(timeStamp: (String(cString: col5) as NSString).doubleValue)
                        }
                        
                        self.addTextToFile(atUrl: tccWriteFile, text: "\(client),\(service),\(authValue),\(authReason),\(last_modified)")
                        self.addTextToFile(atUrl: storylineFile , text: "\(last_modified),tcc_\(authValue),\(service),\(client)")
                    }
                }
            } else {
                self.log("An error occurred when attempting to query the raw TCC database for \(tcc_path.path)...")
            }
        }
    }
    
    func parseLSQuarantine() {
        
        self.addTextToFile(atUrl: self.quarantineWriteFile, text: "timestamp, agent_name, bundle_id, data_url, origin_url, sender_name, sender_address")
        
        let rawDir = "\(self.collectionDir)/Artifacts/raw/"
        var quarantineFiles = [URL]()
        for f in filemanager.filesInDir(path: rawDir) {
            if f.lastPathComponent.contains("lsquarantine") {
                quarantineFiles.append(f)
            }
        }
        
        for fileURL in quarantineFiles {
        
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
                        // in CFAbsolute Time / Mac Absolute time
                        if let col1 = sqlite3_column_text(queryStatement, 0) {
                            LSQuarantineTimeStamp = Aftermath.dateFromEpochTimestamp(timeStamp: (String(cString: col1) as NSString).doubleValue + 978307200) // adding 978307200 converts CFAbsolute to Epoch
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
                        
                        self.addTextToFile(atUrl: self.quarantineWriteFile, text: "\(LSQuarantineTimeStamp),\(LSQuarantineAgentName),\(LSQuarantineAgentBundleIdentifier),\(LSQuarantineDataURLString),\(LSQuarantineOriginURLString),\(LSQuarantineSenderName),\(LSQuarantineSenderAddress)")
                        
                        if LSQuarantineDataURLString != "" || LSQuarantineOriginURLString != "" {
                            self.addTextToFile(atUrl: storylineFile, text: "\(LSQuarantineTimeStamp),lsquarantine_\(LSQuarantineAgentName),\(LSQuarantineDataURLString),\(LSQuarantineOriginURLString)")
                        }
                    }
                }
            } else {
                self.log("An error occurred when attempting to query the LSQuarantine database...")
            }
        }
    }
    
    func run() {
        self.log("Parsing collected database files")
        self.log("Parsing LSQuarantine database...")
        parseLSQuarantine()
        
        self.log("Parsing TCC database...")
        parseTCC()
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
    
    /*
     Compiled from /System/Library/PrivateFrameworks/TCC.framework/Resources/en.lproj/Localizable.strings and https://rainforest.engineering/2021-02-09-macos-tcc/
     */
    enum TCCService: String, CaseIterable {
        // critical
        case location = "kTCCServiceLiverpool"
        case icloud = "kTCCServiceUbiquity"
        case sharing = "kTCCServiceShareKit"
        case fda = "kTCCServiceSystemPolicyAllFiles"
        
        // common
        case accessibility = "kTCCServiceAccessibility"
        case keystrokes = "kTCCServicePostEvent"
        case inputMonitoring = "kTCCServiceListenEvent"
        case developerTools = "kTCCServiceDeveloperTool"
        case screenCapture = "kTCCServiceScreenCapture"
        
        // file access
        case adminFiles = "kTCCServiceSystemPolicySysAdminFiles"
        case desktopFolder = "kTCCServiceSystemPolicyDesktopFolder"
        case developerFiles = "kTCCServiceSystemPolicyDeveloperFiles"
        case documentsFolder = "kTCCServiceSystemPolicyDocumentsFolder"
        case downloadsFolder = "kTCCServiceSystemPolicyDownloadsFolder"
        case networkVolumes = "kTCCServiceSystemPolicyNetworkVolumes"
        
        // service access
        case addressBook = "kTCCServiceAddressBook"
        case appleEvents = "kTCCServiceAppleEvents"
        case availability = "kTCCServiceUserAvailability"
        case bluetooth_always = "kTCCServiceBluetoothAlways"
        case calendar = "kTCCServiceCalendar"
        case camera = "kTCCServiceCamera"
        case contacts_full = "kTCCServiceContactsFull"
        case contacts_limited = "kTCCServiceContactsLimited"
        case currentLocation = "kTCCServiceLocation"
        case fileAccess = "kTCCServiceFileProviderDomain"
        case fileAccess_request = "kTCCServiceFileProviderPresence"
        case fitness = "kTCCServiceMotion"
        case focus_notifications = "kTCCServiceFocusStatus"
        case gamecenter = "kTCCServiceGameCenterFriends"
        case homeData = "kTCCServiceWillow"
        case mediaLibrary = "kTCCServiceMediaLibrary"
        case microphone = "kTCCServiceMicrophone"
        case photos = "kTCCServicePhotos"
        case photos_add = "kTCCServicePhotosAdd"
        case proto3Right = "kTCCServicePrototype3Rights"
        case reminders = "kTCCServiceReminders"
        case removableVolumes = "kTCCServiceSystemPolicyRemovableVolumes"
        case siri = "kTCCServiceSiri"
        case speechRecognition = "kTCCServiceSpeechRecognition"
    }
}

extension Collection where Indices.Iterator.Element == Index {
    subscript (safe index: Index) -> Iterator.Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
