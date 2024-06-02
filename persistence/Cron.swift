//
//  Cron.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation


class Cron: PersistenceModule {
    
    let saveToRawDir: URL
    
    init(saveToRawDir: URL) {
        self.saveToRawDir = saveToRawDir
    }
    
    func captureCronTabs(urlLocations: [URL], rawLoc: URL, captured: URL) {
        for url in urlLocations {
            // copy the files to the persistence directory
            do {
                self.copyFileToCase(fileToCopy: url, toLocation: rawLoc)
                self.addTextToFile(atUrl: captured, text: "/n ----- \(url.path) -----/n")
                let contents = try String(contentsOf: url)
                self.addTextToFile(atUrl: captured, text: contents)
            } catch {
                self.log("Unable to copy crontabs file")
            }
            
        }
    }
    
    func captureCronJobs(urlLocations: [URL], rawLoc: URL) {
        for url in urlLocations {
            self.copyFileToCase(fileToCopy: url, toLocation: rawLoc)
        }
    }
    
    func captureAtTabs(urlLocations: [URL], rawLoc: URL) {
        for url in urlLocations {
            self.copyFileToCase(fileToCopy: url, toLocation: rawLoc)
        }
    }
    
    override func run() {
        self.log("Collecting cron jobs...")

        let cronRawDir = self.createNewDir(dir: self.saveToRawDir, dirname: "cron")
        let cronTabsRawDir = self.createNewDir(dir: cronRawDir, dirname: "cron_tabs")
        let cronJobsRawDir = self.createNewDir(dir: cronRawDir, dirname: "cron_jobs")
        let atRawDir = self.createNewDir(dir: cronRawDir, dirname: "at_tabs")
        
        let capturedCronTabs = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "crontabs.txt")
        
        let cronTabsPath = "/usr/lib/cron/tabs/"
        let crontabs = filemanager.filesInDirRecursive(path: cronTabsPath)
        
        let cronJobsPath = "/usr/lib/cron/jobs/"
        let cronjobs = filemanager.filesInDirRecursive(path: cronJobsPath)
        
        let atTabsPath = "/var/at/tabs/"
        let tabs = filemanager.filesInDirRecursive(path: atTabsPath)
        
        captureCronTabs(urlLocations: crontabs, rawLoc: cronTabsRawDir, captured: capturedCronTabs)
        captureCronJobs(urlLocations: cronjobs, rawLoc: cronJobsRawDir)
        captureAtTabs(urlLocations: tabs, rawLoc: atRawDir)
        
        populatePB(capturedCronTabs)
    }
}
