//
//  CommonDirectories.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 6/17/22.
//

import Foundation

class CommonDirectories: FileSystemModule {
    
    let writeFile: URL
    var isAftermath: Bool = false
    
    init(writeFile: URL) {
        self.writeFile = writeFile
    }
    
    func dumpTmp(tmpDir: String, tmpRawDir: URL) {
        
        isAftermath = false
        
        for file in filemanager.filesInDirRecursive(path: tmpDir) {
            
            for p in file.pathComponents {
                if p.contains("Aftermath") {
                    isAftermath = true
                    break
                }
            }
            if isAftermath { continue }
            self.copyFileToCase(fileToCopy: file, toLocation: tmpRawDir)
        }
    }
    
    func dumpTrash(trashRawDir: URL) {
        
        isAftermath = false
        
        for user in getBasicUsersOnSystem() {
            let path = "\(user.homedir)/.Trash"

            for file in filemanager.filesInDirRecursive(path: path) {
                for p in file.pathComponents {
                    if p.contains("Aftermath") {
                        isAftermath = true
                        break
                    }
                }
                self.copyFileToCase(fileToCopy: file, toLocation: trashRawDir)
            }
        }
    }
    
    func dumpDownloads(downloadsRawDir: URL) {
        
        for user in getBasicUsersOnSystem() {
            let path = "\(user.homedir)/Downloads"
            
            for file in filemanager.filesInDirRecursive(path: path) {
                if file.lastPathComponent == ".DS_Store" { continue }
                self.copyFileToCase(fileToCopy: file, toLocation: downloadsRawDir)
            }
        }
    }
    
    override func run() {
        self.log("Capturing data from common directories...")
        
        self.log("Dumping tmp directory...")
        let tmpRawDir = self.createNewDir(dir: self.rawDir, dirname: "tmp_files")
        dumpTmp(tmpDir: "/tmp", tmpRawDir: tmpRawDir)
        
        self.log("Dumping the Trash...")
        let trashRawDir = self.createNewDir(dir: self.rawDir, dirname: "trash")
        dumpTrash(trashRawDir: trashRawDir)
        
        self.log("Dumping the Downloads directory")
        let downloadsRawDir = self.createNewDir(dir: self.rawDir, dirname: "downloads")
        dumpDownloads(downloadsRawDir: downloadsRawDir)
    }
}
