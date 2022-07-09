//
//  TCC.swift
//  aftermath
//
//

import Foundation
import SQLite3
import AppKit

class TCC: ArtifactsModule {
    
    let tccDir: URL
    
    init(tccDir: URL) {
        self.tccDir = tccDir
    }
    
    fileprivate func queryTCC(_ tcc_path: URL, _ capturedTCC: URL, _ appendedName: String) {
        var db : OpaquePointer?
        
        if sqlite3_open(tcc_path.path, &db) == SQLITE_OK {
            var queryStatement: OpaquePointer? = nil
            let queryString = "select client, auth_value, auth_reason, service from access"
            
            if sqlite3_prepare_v2(db, queryString, -1, &queryStatement, nil) == SQLITE_OK {
                var client: String = ""
                var authValue: String = ""
                var authReason: String = ""
                var service: String = ""
                
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
                    
                    self.addTextToFile(atUrl: capturedTCC, text: "Name: \(client)\nRequested Service: \(service)\nAuth Value: \(authValue)\nAuth Reason: \(authReason)\n")
                }
            }
        } else {
            self.log("An error occurred when attempting to query the TCC database for \(appendedName)...")
        }
    }
    
    func getTCC() {

        let capturedTCC = self.createNewCaseFile(dirUrl: self.moduleDirRoot, filename: "tccItems.txt")
        
        var tcc_paths = [URL(fileURLWithPath: "/Library/Application Support/com.apple.TCC/TCC.db")]
        
        for user in getBasicUsersOnSystem() {
            let tcc_path = URL(fileURLWithPath:"\(user.homedir)/Library/Application Support/com.apple.TCC/TCC.db")
            if !filemanager.fileExists(atPath: tcc_path.relativePath) { continue }

            tcc_paths.append(tcc_path)
        }
        
        for tcc_path in tcc_paths {
            var appendedName: String
            if tcc_path.pathComponents[1] == "Library" {
                appendedName = "root"
            } else {
                appendedName = tcc_path.pathComponents[2]
            }
            
            self.copyFileToCase(fileToCopy: tcc_path, toLocation: tccDir, newFileName: "tcc_\(appendedName)")
            
            self.addTextToFile(atUrl: capturedTCC, text: "TCC Data for \(appendedName)")
            queryTCC(tcc_path, capturedTCC, appendedName)
            self.log("Finished TCC query on TCC database for \(appendedName)")
        }
    
        self.log("Finished querying TCC")
    }
    
    override func run() {
        self.log("Collecting TCC information...")
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

