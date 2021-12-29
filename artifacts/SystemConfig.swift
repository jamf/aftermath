//
//  SystemConfig.swift
//  aftermath
//
//

import Foundation
import AppKit


class SystemConfig: ArtifactsModule {
    
    let fm: FileManager
    let systemConfigDir: URL
    let user = NSUserName()
    lazy var writeFile = self.createNewCaseFile(dirUrl: self.moduleDirRoot, filename: "systemConfig.txt")
    
    init(systemConfigDir: URL) {
        self.systemConfigDir = systemConfigDir
        self.fm = FileManager.default
    }
    
    func copyHostsFile() {
        let _ = copySingleArtifact(path: "/etc/hosts", isDir: false)
    }
    
    func copySSHContents() {
        let _ = copySingleArtifact(path: "/etc/ssh/", isDir: true)
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
        let _ = copySingleArtifact(path: "/Users/\(user)/.ssh/", isDir: true)
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
        
        self.copyFileToCase(fileToCopy: url, toLocation: self.systemConfigDir)
        self.addTextToFile(atUrl: self.writeFile, text: "\n----- \(url) -----\n\(plistDict)\n")
    }
    
    func copySingleArtifact(path: String, isDir: Bool) {
        if !isDir {
            let file = URL(fileURLWithPath: path)
            
            let _ = self.copyFileToCase(fileToCopy: file, toLocation: self.systemConfigDir)
            self.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
        }
        if isDir {
            let files = fm.filesInDirRecursive(path: path)
            
            for file in files {
                if file.lastPathComponent == "moduli" { continue } // used by sshd, unnecessary for us

                let _ = self.copyFileToCase(fileToCopy: file, toLocation: self.systemConfigDir)
                self.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
            }
        }
    }
    
    override func run() {
        self.log("Collecting etc information...")
        copyHostsFile()
        copySSHContents()
        copySudoers()
        copyResolvDNS()
        copyEtcProfile()
        copyKcPassword()
        
        self.log("Collecting user ssh information...")
        copyUserSSH()
        
        self.log("Collecting launch overrides...")
        captureOverrides()
    }
}

