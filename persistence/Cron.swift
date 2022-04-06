//
//  Cron.swift
//  aftermath
//
//
import Foundation


class Cron: PersistenceModule {
    
    let saveToRawDir: URL
    
    init(saveToRawDir: URL) {
        self.saveToRawDir = saveToRawDir
    }
    
    func captureCronJobs(urlLocations: [URL], toLocation: URL) {
        for url in urlLocations {
            // copy the files to the persistence directory
            self.copyFileToCase(fileToCopy: url, toLocation: toLocation)
            
        }
    }
    
    override func run() {
        let cronRawDir = self.createNewDir(dir: self.saveToRawDir, dirname: "cron_dump")
        
        let cronjobsPath = "/usr/lib/cron/tabs/"
        let cronjobs = filemanager.filesInDirRecursive(path: cronjobsPath)
        
        captureCronJobs(urlLocations: cronjobs, toLocation: cronRawDir)
    }
}
