//
//  LoginHooks.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class LoginHooks: PersistenceModule {
    
    let hooks: String
    let saveToRawDir: URL
    
    init(saveToRawDir: URL) {
        self.hooks = "/Library/Preferences/com.apple.loginwindow.plist"
        self.saveToRawDir = saveToRawDir
    }
    
    private func parseHooks(hooksFile: URL) -> String? {
        let hooksFromFile = Aftermath.getPlistAsDict(atUrl: hooksFile)
        var parsedHooks: String?
        for (x,y) in hooksFromFile {
            if x == "LoginHook" || x == "LogoutHook" {
                let hook = ("\(x): \(y)")
                self.copyFileToCase(fileToCopy: URL(fileURLWithPath: String(describing: y)), toLocation: self.saveToRawDir)
                if let _ = parsedHooks {
                    parsedHooks! += hook
                } else {
                    parsedHooks = hook
                }
            }
        }
        
        return parsedHooks
    }
    
    override func run() {
        self.log("Collecting login hooks...")
        let userFm = filemanager.homeDirectoryForCurrentUser.path
        let path = "\(userFm)\(self.hooks)"
        let url = URL(fileURLWithPath: path)
        let hooksParsed = parseHooks(hooksFile: url)
        if let hooksParsed = hooksParsed {
            let hooksSaveFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "hooks.txt")
            self.addTextToFile(atUrl: hooksSaveFile, text: hooksParsed)
        }
        
        
        
        self.copyFileToCase(fileToCopy: url, toLocation: self.saveToRawDir)
    }
}
