//
//  PersistenceHandler.swift
//  aftermath
//
//

import Foundation


class PersistenceModule: AftermathModule, AMProto {
    let name = "Persistence Module"
    let dirName = "Persistence"
    let description = "A module for collecting Auto Start Execution Points"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
    func run() {
        let persistenceRawDir = self.createNewDirInRoot(dirName: "\(dirName)/raw")
        
        // capture the launch items
        self.log("Collecting launchagents and launchdaemons...")
        let launch = LaunchItems(saveToRawDir: persistenceRawDir)
        launch.run()
        
        
        // get the login and logout hooks
        self.log("Collecting login hooks...")
        let hooks = LoginHooks(saveToRawDir: persistenceRawDir)
        hooks.run()
        
        self.log("Collecting cron jobs...")
        let cron = Cron(saveToRawDir: persistenceRawDir)
        cron.run()
        
        self.log("Collecting overrides...")
        let overrides = Overrides(saveToRawDir: persistenceRawDir)
        overrides.run()
    }
}
