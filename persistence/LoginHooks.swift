//
//  LoginHooks.swift
//  aftermath
//
//

import Foundation

class LoginHooks {
    
    let caseHandler: CaseHandler
    let hooks: String
    let saveToDir: URL
    let saveToRawDir: URL
    
    init(caseHandler: CaseHandler, saveToDir: URL, saveToRawDir: URL) {
        self.caseHandler = caseHandler
        self.hooks = "/Library/Preferences/com.apple.loginwindow.plist"
        self.saveToDir = saveToDir
        self.saveToRawDir = saveToRawDir
    }
    
    private func parseHooks(hooksFile: URL) -> String? {
        let hooksFromFile = Aftermath.getPlistAsDict(atUrl: hooksFile)
        var parsedHooks: String?
        for (x,y) in hooksFromFile {
            if x == "LoginHook" || x == "LogoutHook" {
                let hook = ("\(x): \(y)")
                if let _ = parsedHooks {
                    parsedHooks! += hook
                } else {
                    parsedHooks = hook
                }
            } else { continue }
        }
        
        return parsedHooks
    }
    
    func run() {
        let userFm = FileManager.default.homeDirectoryForCurrentUser.path
        let path = "\(userFm)\(self.hooks)"
        let url = URL(fileURLWithPath: path)
        let hooksParsed = parseHooks(hooksFile: url)
        if let hooksParsed = hooksParsed {
            let hooksSaveFile = caseHandler.createNewCaseFile(dirUrl: saveToDir, filename: "hooks.txt")
            caseHandler.addTextToFile(atUrl: hooksSaveFile, text: hooksParsed)
        }
        
        
        self.caseHandler.copyFileToCase(fileToCopy: url, toLocation: self.saveToRawDir)
    }
}
