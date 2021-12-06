//
//  SystemConfig.swift
//  aftermath
//
//

import Foundation

class SystemConfig {
    
    let caseHandler: CaseHandler
    let artifactsDir: URL
    let etcDir: URL
    let fm: FileManager
    let writeFile: URL
    
    init(caseHandler: CaseHandler, artifactsDir: URL, etcDir: URL) {
        self.caseHandler = caseHandler
        self.artifactsDir = artifactsDir
        self.etcDir = etcDir
        self.fm = FileManager.default
        self.writeFile = self.caseHandler.createNewCaseFile(dirUrl: self.artifactsDir, filename: "etc.txt")
    }
    
    func copyHostsFile() {
        let file = URL(fileURLWithPath: "/etc/hosts")
        let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.etcDir)
        self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
    }
    
    func copySSHContents() {
        let dir = "/etc/ssh/"
        let files = fm.filesInDirRecursive(path: dir)
        
        for file in files {
            if file.lastPathComponent == "moduli" { continue } // used by sshd, unnecessary for us
            let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.etcDir)
            self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
        }
    }
    
    func copySudoers() {
        let file = URL(fileURLWithPath: "/etc/sudoers")
        let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.etcDir)
        self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
    }
    
    func copyUserSSH() {
        let user = NSUserName()
        let dir = "/Users/\(user)/.ssh/"
        let files = fm.filesInDirRecursive(path: dir)
        
        for file in files {
            let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.etcDir)
            self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
        }
    }
    
    func run() {
        self.caseHandler.log("Collecting etc information...")
        copyHostsFile()
        copySSHContents()
        copySudoers()
        self.caseHandler.log("Collecting user ssh information...")
        copyUserSSH()
    }
}
