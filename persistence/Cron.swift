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
    
    func captureCronJobs(urlLocations: [URL], rawLoc: URL, captured: URL) {
        for url in urlLocations {
            // copy the files to the persistence directory
            do {
                self.copyFileToCase(fileToCopy: url, toLocation: rawLoc)
                self.addTextToFile(atUrl: captured, text: "/n ----- \(url) -----/n")
                let contents = try String(contentsOf: url)
                self.addTextToFile(atUrl: captured, text: contents)
            } catch {
                self.log("Unable to copy crontabs file")
            }
            
        }
    }
    
    override func run() {
        self.log("Collecting cron jobs...")

        let cronRawDir = self.createNewDir(dir: self.saveToRawDir, dirname: "cron_dump")
        
        let capturedCronJobs = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "crontabs.txt")
        
        let cronjobsPath = "/usr/lib/cron/tabs/"
        let cronjobs = filemanager.filesInDirRecursive(path: cronjobsPath)
        
        captureCronJobs(urlLocations: cronjobs, rawLoc: cronRawDir, captured: capturedCronJobs)
    }
}
