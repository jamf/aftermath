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
    
    func populatePB(_ url: URL) {
        if(false == enablePB) {
            return
        }
        
        do {
            var cf = CaseFile()
            cf.pathname = url.absoluteString
            cf.filetype = .text
            cf.text = try String(contentsOf: url)
            self.report.pers.casefiles.updateValue(cf, forKey: url.absoluteString)
        } catch {
            print("Error setting case file: \(url.absoluteString)")
        }
    }
    
    func run() {
        
        self.log("Starting Persistence Module")

        let persistenceRawDir = self.createNewDirInRoot(dirName: "\(dirName)/raw")
        
        // capture the launch items
        let launch = LaunchItems(saveToRawDir: persistenceRawDir)
        launch.run()
        
        // get the login and logout hooks
        let hooks = LoginHooks(saveToRawDir: persistenceRawDir)
        hooks.run()
        
        // capture all cron tabs
        let cron = Cron(saveToRawDir: persistenceRawDir)
        cron.run()
        
        // collect overrides file
        let overrides = Overrides(saveToRawDir: persistenceRawDir)
        overrides.run()
        
        // write out all system extensions
        let systemExtensions = SystemExtensions(saveToRawDir: persistenceRawDir)
        systemExtensions.run()
        
        // collect any periodic scripts
        let periodicScripts = Periodic(saveToRawDir: persistenceRawDir)
        periodicScripts.run()
        
        // on older OSs, collect emond
        let emond = Emond(saveToRawDir: persistenceRawDir)
        emond.run()
        
        // gather all Login Items
        let loginItems = LoginItems(saveToRawDir: persistenceRawDir)
        loginItems.run()
        
        // dump the BTM file
        let btmParser = BTM()
        btmParser.run()
        
        do {
            try self.report.merge(serializedData: launch.getReport().serializedData())
            try self.report.merge(serializedData: hooks.getReport().serializedData())
            try self.report.merge(serializedData: cron.getReport().serializedData())
            try self.report.merge(serializedData: overrides.getReport().serializedData())
            try self.report.merge(serializedData: systemExtensions.getReport().serializedData())
            try self.report.merge(serializedData: periodicScripts.getReport().serializedData())
            try self.report.merge(serializedData: emond.getReport().serializedData())
            try self.report.merge(serializedData: loginItems.getReport().serializedData())
            try self.report.merge(serializedData: btmParser.getReport().serializedData())

        } catch {
            
        }

        self.log("Finished gathering persistence mechanisms")
    }
}
