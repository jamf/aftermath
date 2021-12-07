//
//  SystemConfig.swift
//  aftermath
//
//

import Foundation
import AppKit

class SystemConfig {
    
    let caseHandler: CaseHandler
    let artifactsDir: URL
    let sysConfigDir: URL
    let fm: FileManager
    let writeFile: URL
    let user = NSUserName()
    
    init(caseHandler: CaseHandler, artifactsDir: URL, sysConfigDir: URL) {
        self.caseHandler = caseHandler
        self.artifactsDir = artifactsDir
        self.sysConfigDir = sysConfigDir
        self.fm = FileManager.default
        self.writeFile = self.caseHandler.createNewCaseFile(dirUrl: self.artifactsDir, filename: "sysConfig.txt")
    }
    
    func copyHostsFile() {
        let _ = copySingleArtifact(path: "etc/hosts", isDir: false)
    }
    
    func copySSHContents() {
        let _ = copySingleArtifact(path: "etc/ssh/", isDir: true)
    }
    
    func copySudoers() {
        let _ = copySingleArtifact(path: "/etc/sudoers", isDir: false)
    }
    
    func copyEtcProfile() {
        let _ = copySingleArtifact(path: "/etc/profile", isDir: false)
    }
    
    func copyResolvDNS() {
        let _ = copySingleArtifact(path: "/private/var/run/resolv.conf", isDir: false)
    }
    
    func copyUserSSH() {
        let _ = copySingleArtifact(path: "Users/\(user)/.ssh/", isDir: true)
    }
    
    func copyKcPassword() {
        let fileString = "/etc/kcpassword"
        if fm.fileExists(atPath: fileString) {
            let _ = copySingleArtifact(path: fileString, isDir: false)
        }
    }
    
    func captureOverrides() {
        let url = URL(fileURLWithPath: "/var/db/launchd.db/com.apple.launchd/overrides.plist")
        let plistDict = Aftermath.getPlistAsDict(atUrl: url)
        
        self.caseHandler.copyFileToCase(fileToCopy: url, toLocation: self.sysConfigDir)
        self.caseHandler.addTextToFile(atUrl: self.writeFile, text: "\n----- \(url) -----\n\(plistDict)\n")
    }
    
    func copySingleArtifact(path: String, isDir: Bool) {
        if !isDir {
            let file = URL(fileURLWithPath: path)
            
            let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.sysConfigDir)
            self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
        }
        if isDir {
            let files = fm.filesInDirRecursive(path: path)
            
            for file in files {
                if file.lastPathComponent == "moduli" { continue } // used by sshd, unnecessary for us

                let _ = self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.sysConfigDir)
                self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
            }
        }
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
