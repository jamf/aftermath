//
//  PersistenceHandler.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation


class PersistenceModule: AftermathModule, AMProto {
    let name = "Persistence Module"
    let dirName = "Persistence"
    let description = "A module for collecting Auto Start Execution Points"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
    func run() {
        
        self.log("Starting Persistence Module")

        let persistenceRawDir = self.createNewDirInRoot(dirName: "\(dirName)/raw")
        
        // capture the launch items
        let launch = LaunchItems(saveToRawDir: persistenceRawDir)
        launch.run()
        
        // get the login and logout hooks
        let hooks = LoginHooks(saveToRawDir: persistenceRawDir)
        hooks.run()
        
        let cron = Cron(saveToRawDir: persistenceRawDir)
        cron.run()
        
        let overrides = Overrides(saveToRawDir: persistenceRawDir)
        overrides.run()
        
        let systemExtensions = SystemExtensions(saveToRawDir: persistenceRawDir)
        systemExtensions.run()
        
        let periodicScripts = Periodic(saveToRawDir: persistenceRawDir)
        periodicScripts.run()
        
        let emond = Emond(saveToRawDir: persistenceRawDir)
        emond.run()
        
        let loginItems = LoginItems(saveToRawDir: persistenceRawDir)
        loginItems.run()
        
        self.log("Finished gathering persistence mechanisms")

    }
}
