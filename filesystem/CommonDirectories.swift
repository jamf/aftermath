//
//  CommonDirectories.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class CommonDirectories: FileSystemModule {
    
    let writeFile: URL
    var isAftermath: Bool = false
    let collectDirs: [String]
    
    init(writeFile: URL, collectDirs: [String]) {
        self.writeFile = writeFile
        self.collectDirs = collectDirs
    }
    
    func writeTmpPaths(tmpDir: String) {
                
        self.addTextToFile(atUrl: self.writeFile, text: "\n\nContents of \(tmpDir)\n")

        for file in filemanager.filesInDirRecursive(path: tmpDir) {
            if isAftermathDir(directory: file) { continue }
            self.addTextToFile(atUrl: self.writeFile, text: "\(file.path)")
        }
    }
    
    func writeTrashPaths() {
        
        for user in getBasicUsersOnSystem() {
            let path = "\(user.homedir)/.Trash"

            self.addTextToFile(atUrl: self.writeFile, text: "\n\nContents of \(path)\n")
            
            for file in filemanager.filesInDirRecursive(path: path) {
                if isAftermathDir(directory: file) { continue }
                self.addTextToFile(atUrl: self.writeFile, text: "\(file.path)")
            }
        }
    }
    
    func writeDownloadsPaths() {

        for user in getBasicUsersOnSystem() {
            let path = "\(user.homedir)/Downloads"
            self.addTextToFile(atUrl: self.writeFile, text: "\n\nContents of \(path)\n")

            for file in filemanager.filesInDirRecursive(path: path) {
                if isAftermathDir(directory: file) { continue }
                if file.lastPathComponent == ".DS_Store" { continue }
                self.addTextToFile(atUrl: self.writeFile, text: "\(file.path)")
            }
        }
    }
    
    private func isAftermathDir(directory: URL) -> Bool {
        
        var isAftermath: Bool = false
        for component in directory.pathComponents {
            if component.contains("Aftermath") {
                isAftermath = true
            } else {
                continue
            }
        }
        return isAftermath
    }
    
    func collectContents(directory: String) {

        let rawDir = self.createNewDir(dir: self.rawDir, dirname: URL(fileURLWithPath: directory).lastPathComponent)
        self.addTextToFile(atUrl: self.writeFile, text: "\n\nContents of \(directory)\n")
        
        for file in filemanager.filesInDirRecursive(path: directory) {
            if isAftermathDir(directory: file) { continue }
            if file.lastPathComponent == ".DS_Store" { continue }
            self.addTextToFile(atUrl: self.writeFile, text: "\(file.path)")
            self.copyFileToCase(fileToCopy: file, toLocation: rawDir)
        }
        
    }
    
    func run() {
        self.log("Capturing data from common directories...")
        
        if collectDirs != [] {
            for dir in collectDirs {
                self.log("Dumping the contents from directory \(dir)")
                collectContents(directory: dir)
            }
        }
        
        self.log("Writing the files in the tmp directory...")
        writeTmpPaths(tmpDir: "/tmp")

        self.log("Writing the file names in the Trash...")
        writeTrashPaths()

        self.log("Writing the file paths of Downloads directory")
        writeDownloadsPaths()
    }
}
