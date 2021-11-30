//
//  PersistenceHandler.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 11/19/21.
//

import Foundation

class PersistenceModule {
    
    let caseHandler: CaseHandler
    let hooks: String
    let launchDaemonsPath: String
    let launchAgentsPath: String
    let persistenceDir: URL
    let aftermathHooksDir: URL
    let aftermathLaunchDir: URL
    
    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        self.hooks = "/Library/Preferences/com.apple.loginwindow.plist"
        self.launchDaemonsPath = "/Library/LaunchDaemons/"
        self.launchAgentsPath = "/Library/LaunchAgents/"
        
        self.persistenceDir = caseHandler.createNewDir(dirName: "persistence")
        self.aftermathHooksDir = caseHandler.createNewDir(dirName: "persistence/hooks_raw")
        self.aftermathLaunchDir = caseHandler.createNewDir(dirName: "persistence/launchItems_raw")
    }
    
    func enumeratePath(path: String) -> [URL] {
        let url = URL(fileURLWithPath: path)
        var files = [URL]()

        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey]) {
            for case let fileURL as URL in enumerator {
                do { let fileAttr = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                    if fileAttr.isRegularFile! {
                        files.append(fileURL)
                    }
                } catch {
                    self.caseHandler.log("Error: \(error) at URL: \(fileURL)")
                }
            }
        }
        return files
    }
    
    func getPlistAsDict(atUrl: URL) -> [String: Any] {
        var data = Data()
        var plistDict = [String:Any]()
        do {
            data = try Data(contentsOf: atUrl)
            plistDict = try PropertyListSerialization.propertyList(from: data, format: nil) as! [String:Any]
        } catch {
            self.caseHandler.log("Could not read \(atUrl.relativePath) due to \(error)")
            return plistDict
        }
        return plistDict
    }
    
    func captureLaunchData(urlLocations: [URL], capturedLaunchFile: URL) {
        self.caseHandler.log("Copying plists to aftermath persistence directory...")
        
        for url in urlLocations {
            let plistDict = getPlistAsDict(atUrl: url)
            
            // copy the plists to the persistence directory
            self.caseHandler.copyFileToCase(fileToCopy: url, toLocation: self.aftermathLaunchDir)
            // write the plists to one file
            self.caseHandler.addTextToFile(atUrl: capturedLaunchFile, text: "\n----- \(url) -----\n")
            self.caseHandler.addTextToFile(atUrl: capturedLaunchFile, text: plistDict.description)
        }
        self.caseHandler.log("Completed copying and writing plists to aftermath directory...")
    }
    
    // TODO
    func pivotToBinary(binaryUrl: URL) {
        
    }
                                          
    func getHooks(path: String) {
        let userFm = FileManager.default.homeDirectoryForCurrentUser.path
        let path = "\(userFm)\(self.hooks)"
        let url = URL(fileURLWithPath: path)
    
        let _ = getPlistAsDict(atUrl: url)
        self.caseHandler.log("Saving hooks to aftermath...")
        self.caseHandler.copyFileToCase(fileToCopy: url, toLocation: self.aftermathHooksDir)
    
        // TODO
//        for (x,y) in hooksPlistAsDict {
//            if x == "LoginHook" || x == "LogoutHook" {
//                print("\(x): \(y)")
//            } else { continue }
//        }
    }
    
    func start() {
        let launchDaemons = enumeratePath(path: self.launchDaemonsPath)
        let launchAgents = enumeratePath(path: self.launchAgentsPath)
        
        // get the login and logout hooks
        getHooks(path: self.hooks)
        
        // capture the launch items
        let capturedLaunchFile = self.caseHandler.createNewCaseFile(dirUrl: self.persistenceDir, filename: "launchItems.txt")
        captureLaunchData(urlLocations: launchDaemons, capturedLaunchFile: capturedLaunchFile)
        captureLaunchData(urlLocations: launchAgents, capturedLaunchFile: capturedLaunchFile)
    }
}
