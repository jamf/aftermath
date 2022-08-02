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
    
    func runScanner(directories: [String]) {
        
      
        self.log("Scanning requested directories...")
        
        for p in directories {
            self.log("Querying directory \(p)")
            let directory = filemanager.filesInDirRecursive(path: p)
            for file in directory {
                
                self.getFileMetadata(fromFile: file)
            }
        }
    }
    
    override func run() {
        
        var directories = ["/tmp", "/opt", "/Library/LaunchDaemons", "/Library/LaunchAgents"]
        
        self.log("Crawling directories for modified and accessed timestamps")
       
        if (deepScan == true) {
            // deep scan will walk the entire user's home directory
            self.log("Performing a deep scan...")
            
            for user in getBasicUsersOnSystem() {
                directories.append("\(user.homedir)")
            }
            
            runScanner(directories: directories)
            
        } else {
            self.log("Performing a default scan...")
            
            for user in getBasicUsersOnSystem() {
                directories.append("\(user.homedir)/Library/Application Support")
                directories.append("\(user.homedir)/Library/LaunchAgents")
                directories.append("\(user.homedir)/Downloads")
                directories.append("\(user.homedir)/Documents")
            }

            runScanner(directories: directories)
        }

        self.log("Finished walkin")
    }
}
