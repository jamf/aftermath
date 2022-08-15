//
//  LoginItems.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 7/29/22.
//

import Foundation

class LoginItems: PersistenceModule {
    
    let saveToRawDir: URL
    
    init(saveToRawDir: URL) {
        self.saveToRawDir = saveToRawDir
    }
    
    func captureLoginItems(rawDir: URL) {
        
        for user in getBasicUsersOnSystem() {
            
            if user.username == "root" { continue }
            let loginItemPlist = URL(fileURLWithPath: "\(user.homedir)/Library/Application Support/com.apple.backgroundtaskmanagementagent/backgrounditems.btm")
            self.copyFileToCase(fileToCopy: loginItemPlist, toLocation: rawDir)
        }
    }
    
    override func run() {
        self.log("Capturing Login Items...")
        
        let loginItemsRaw = self.createNewDir(dir: self.saveToRawDir, dirname: "login_items")
        captureLoginItems(rawDir: loginItemsRaw)
    }
}
