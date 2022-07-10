//
//  FileWalker.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 6/21/22.
//

import Foundation

class FileWalker: FileSystemModule {
    
    let writeFile: URL

    
    init(writeFile: URL) {
        self.writeFile = writeFile
    }
    
    func deepScanner() {
        
    }
    
    func defaultScanner() {
        
        var directories = ["/tmp", "/opt", "/Library/LaunchDaemons", "/Library/LaunchAgents"]
        
        for user in getBasicUsersOnSystem() {
            directories.append("\(user.homedir)/Library/Application Support")
            directories.append("\(user.homedir)/Library/LaunchAgents")
            directories.append("\(user.homedir)/Downloads")
            directories.append("\(user.homedir)/Documents")
        }
        self.log("Scanning default directories...")
        
        for p in directories {
            self.log("Querying directory \(p)")
            let directory = filemanager.filesInDirRecursive(path: p)
            for file in directory {
                
                self.getFileMetadata(fromFile: file)
            }
        }
    }
    
    // TODO - FDA
    // in utc
    override func run() {
        self.log("Crawling directories for modified and accessed timestamps")
       
        if (deepScan == true) {
            self.log("Performing a deep scan...")
            deepScanner()
        } else {
            self.log("Performing a default scan...")

            defaultScanner()
        }

        self.log("Finished walkin")
    }
}
