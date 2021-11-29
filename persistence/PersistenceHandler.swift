//
//  PersistenceHandler.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 11/19/21.
//

import Foundation

class PersistenceHandle {
    
    let caseHandler: CaseHandler
    let hooks: String
    let launchDaemonsPath: String
    let launchAgentsPath: String
    let persistenceDir: URL
    let aftermathHooksDir: URL
    let aftermathLaunchDir: URL
    
    init() {
        self.caseHandler = CaseHandler()
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
                    print(error, fileURL)
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
            print("Could not read \(atUrl.relativePath)")
            print(error)
            return plistDict
        }
        return plistDict
    }
    
    func captureLaunchData(urlLocations: [URL]) {
        print("Capturing...")
        
        let capturedLaunchFile = self.caseHandler.createNewCaseFile(dirUrl: self.persistenceDir, filename: "launchItems.txt")
     
        for url in urlLocations {
            let plistDict = getPlistAsDict(atUrl: url)
            
            // copy the plists to the persistence directory
            self.caseHandler.copyFileToCase(fileToCopy: url, toLocation: self.aftermathLaunchDir)
            // write the plists to one file
            self.caseHandler.addTextToFile(atUrl: capturedLaunchFile, text: "\n----- \(url) -----\n")
            self.caseHandler.addTextToFile(atUrl: capturedLaunchFile, text: plistDict.description)
            
            
            print(plistDict)
        }
    }
    
    // TODO
    func pivotToBinary(binaryUrl: URL) {
        
    }
                                          
    func getHooks(path: String) {
        let userFm = FileManager.default.homeDirectoryForCurrentUser.path
        let path = "\(userFm)\(self.hooks)"
        let url = URL(fileURLWithPath: path)
    
        let hooksPlistAsDict = getPlistAsDict(atUrl: url)
        print(hooksPlistAsDict)
        print("Saving out hooks plist...")
        caseHandler.copyFileToCase(fileToCopy: url, toLocation: self.aftermathHooksDir)
    
        for (x,y) in hooksPlistAsDict {
            if x == "LoginHook" || x == "LogoutHook" {
                print("\(x): \(y)")
            } else { print("No Hooks.")}
        }
    }
    
    func start() {
        let launchDaemons = enumeratePath(path: self.launchDaemonsPath)
        let launchAgents = enumeratePath(path: self.launchAgentsPath)
        
        print("------- Hooks -------")
        getHooks(path: self.hooks)
        
        print("------- Launch Items -------")
        captureLaunchData(urlLocations: launchDaemons)
        captureLaunchData(urlLocations: launchAgents)
    }
}
