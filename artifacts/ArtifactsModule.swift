//
//  ArtifactsModule.swift
//  aftermath
//
//

import Foundation
import SQLite3


// tcc
// lsquarantine
// /etc/sudoers
// /etc/host
// /etc/ssh/.*
// ~/.ssh


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
            let queryString = "select client, auth_value, auth_reason, service from access"
            
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                var client: String = ""
                var authValue: String = ""
                var authReason: String = ""
                var service: String = ""
                
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
                    
                    let col4 = sqlite3_column_text(queryStatement, 3)
                    if col4 != nil {
                        service = String(cString: col4!)
                        for item in TCCService.allCases {
                            if service == String(item.rawValue) {
                                service = String(describing: item)
                            }
                        }
                    }
                    
                    self.caseHandler.addTextToFile(atUrl: capturedTCC, text: "Bundle ID: \(client)\nRequested Service: \(service)\nAuth Value: \(authValue)\nAuth Reason: \(authReason)\n")
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
