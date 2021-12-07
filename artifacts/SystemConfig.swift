//
//  SystemConfig.swift
//  aftermath
//
//

import Foundation

class SystemConfig {
    
    let caseHandler: CaseHandler
    let artifactsDir: URL
    let sysConfigDir: URL
    let fm: FileManager
    let writeFile: URL
    
    init(caseHandler: CaseHandler, artifactsDir: URL, sysConfigDir: URL) {
        self.caseHandler = caseHandler
        self.artifactsDir = artifactsDir
        self.sysConfigDir = sysConfigDir
        self.fm = FileManager.default
        self.writeFile = self.caseHandler.createNewCaseFile(dirUrl: self.artifactsDir, filename: "sysConfig.txt")
    }
    
    func copyHostsFile() {
        let file = URL(fileURLWithPath: "/etc/hosts")
        let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.sysConfigDir)
        self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
    }
    
    func copySSHContents() {
        let dir = "/etc/ssh/"
        let files = fm.filesInDirRecursive(path: dir)
        
        for file in files {
            if file.lastPathComponent == "moduli" { continue } // used by sshd, unnecessary for us
            let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.sysConfigDir)
            self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
        }
    }
    
    func copySudoers() {
        let file = URL(fileURLWithPath: "/etc/sudoers")
        let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.sysConfigDir)
        self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
    }
    
    func copyEtcProfile() {
        let file = URL(fileURLWithPath: "/etc/profile")
        let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.sysConfigDir)
        self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
    }
    
    func copyResolvDNS() {
        let file = URL(fileURLWithPath: "/private/var/run/resolv.conf")
        let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.sysConfigDir)
        self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
    }
    
    func copyKcPassword() {
        let fileString = "/etc/kcpassword"
        if fm.fileExists(atPath: fileString) {
            let file = URL(fileURLWithPath: fileString)
            let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.sysConfigDir)
            self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
        } else {
            self.caseHandler.log("AutoLogin is not enabled - kcpassword file does not exist")
        }
    }
    
    func copyUserSSH() {
        let user = NSUserName()
        let dir = "/Users/\(user)/.ssh/"
        let files = fm.filesInDirRecursive(path: dir)
        
        for file in files {
            let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.sysConfigDir)
            self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
        }
    }
    
    func captureOverrides() {
        let url = URL(fileURLWithPath: "/var/db/launchd.db/com.apple.launchd/overrides.plist")
        let plistDict = Aftermath.getPlistAsDict(atUrl: url)
        
        self.caseHandler.copyFileToCase(fileToCopy: url, toLocation: self.sysConfigDir)
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "\n----- \(url) -----\n\(plistDict)\n")
    }
    
    func run() {
        self.caseHandler.log("Collecting etc information...")
        copyHostsFile()
        copySSHContents()
        copySudoers()
        copyResolvDNS()
        copyEtcProfile()
        copyKcPassword()
        
        self.caseHandler.log("Collecting user ssh information...")
        copyUserSSH()
        
        self.caseHandler.log("Collecting launch overrides...")
        captureOverrides()
    }
}
