//
//  FileWalker.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
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
                if file.path.contains("homebrew") { continue }
                self.getFileMetadata(fromFile: file)
            }
        }
    }
    
    func run() {
        
        var directories = ["/tmp", "/opt", "/Library/LaunchDaemons", "/Library/LaunchAgents"]
        
        self.log("Crawling directories for modified and accessed timestamps")
       
        if Command.options.contains(.deep) {
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

        self.log("Finished walking directories.")
    }
}
