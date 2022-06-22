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
    
    // in utc
    override func run() {
        self.log("Walking docs dir")
        let directory = filemanager.filesInDirRecursive(path: "/Users/stuartashenbrenner/Documents")
        
        for file in directory {
            if let mditem = MDItemCreate(nil, file.path as CFString),
                let mdnames = MDItemCopyAttributeNames(mditem),
                let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any] {
                
                self.addTextToFile(atUrl: self.writeFile, text: "File: \(file.path)")
                
                if let lastAccessed = mdattrs[kMDItemLastUsedDate as String] {
                    self.addTextToFile(atUrl: self.writeFile, text: "Accessed: \(lastAccessed)")
                } else {
                    self.addTextToFile(atUrl: self.writeFile, text: "Accessed: Unknown")
                }
                if let lastModified = mdattrs[kMDItemContentModificationDate as String] {
                    self.addTextToFile(atUrl: self.writeFile, text: "Modified: \(lastModified)\n")
                } else {
                    self.addTextToFile(atUrl: self.writeFile, text: "Modified: Unknown\n")
                }

             } else {
                 print("Can't get attributes for \(file.path)")
             }
        }
        self.log("Finished walkin")
    }
    
    
    enum ignoreDirectory: String, CaseIterable {
         case Lib = ""
    }
    
}


