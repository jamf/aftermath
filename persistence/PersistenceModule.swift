//
//  PersistenceHandler.swift
//  aftermath
//
//

import Foundation


class PersistenceModule {
    
    let caseHandler: CaseHandler
    let hooks: String
    let persistenceDir: URL
    let persistenceRawDir: URL
    
    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        self.hooks = "/Library/Preferences/com.apple.loginwindow.plist"
        self.persistenceDir = caseHandler.createNewDir(dirName: "persistence")
        self.persistenceRawDir = caseHandler.createNewDir(dirName: "persistence/raw")
    }
    
    
    func start() {
        // capture the launch items
        self.caseHandler.log("Collecting launchagents and launchdaemons...")
        let launch = LaunchItems(caseHandler: caseHandler, saveToDir: self.persistenceDir, saveToRawDir: self.persistenceRawDir)
        launch.run()
        
        
        // get the login and logout hooks
        self.caseHandler.log("Collecting login hooks...")
        let hooks = LoginHooks(caseHandler: caseHandler, saveToDir: self.persistenceDir, saveToRawDir: persistenceRawDir)
        hooks.run()
    }
}
