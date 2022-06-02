//
//  Periodic.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 6/2/22.
//

import Foundation

class Periodic: PersistenceModule {
    
    let saveToRawDir: URL
    
    init(saveToRawDir: URL) {
        self.saveToRawDir = saveToRawDir
    }
    
    func capturePeriodicScripts(urlLocations: [URL], capturedScriptsFile: URL, directory: URL) {
        for url in urlLocations {
            
            self.copyFileToCase(fileToCopy: url, toLocation: directory)
            
            do {
                self.addTextToFile(atUrl: capturedScriptsFile, text: "/n ----- \(url) -----/n")
                let contents = try String(contentsOf: url)
                self.addTextToFile(atUrl: capturedScriptsFile, text: contents)
            } catch {
                self.log("Unable to capture periodic scripts")
                
            }
        }
    }
        
    override func run() {
        let root = "/etc/periodic/"
        
        let allScripts = ["daily", "weekly", "monthly"]
        let capturedScriptsFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "periodic.txt")

        
        for loc in allScripts {
            let directory = "\(root)\(loc)/"
            let periodicDir = self.createNewDir(dir: self.saveToRawDir, dirname: "periodic/\(loc)")
            let scripts = filemanager.filesInDirRecursive(path: directory)
            capturePeriodicScripts(urlLocations: scripts, capturedScriptsFile: capturedScriptsFile, directory: periodicDir)

            
            
        }
        

        
    }
}