//
//  BashProfiles.swift
//  aftermath
//
//

import Foundation

class BashProfiles {
    
    let caseHandler: CaseHandler
    let artifactsDir: URL
    let profilesDir: URL
    let writeFile: URL
    let user: String
    
    init(caseHandler: CaseHandler, artifactsDir: URL, profilesDir: URL) {
        self.user = NSUserName()
        self.caseHandler = caseHandler
        self.artifactsDir = artifactsDir
        self.profilesDir = profilesDir
        self.writeFile = self.caseHandler.createNewCaseFile(dirUrl: self.artifactsDir, filename: "bashProfiles.txt")
    }
    
    func copyArtifact(file: URL) {
        if (FileManager.default.fileExists(atPath: file.relativePath)) {
            self.caseHandler.copyFileToCase(fileToCopy: file, toLocation: self.profilesDir)
            self.caseHandler.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
        }
    }
    
    func copyBashHistory() {
        let path = URL(fileURLWithPath: "/Users/\(self.user)/.bash_history")
        copyArtifact(file: path)
    }

    func copyZshHistory() {
        let path = URL(fileURLWithPath: "/Users/\(self.user)/.zsh_history")
        copyArtifact(file: path)
    }
    
    func copyShHistory() {
        let path = URL(fileURLWithPath: "/Users/\(self.user)/.sh_history")
        copyArtifact(file: path)
    }
    
    func copyBashProfile() {
        let path = URL(fileURLWithPath: "/Users/\(self.user)/.bash_profile")
        copyArtifact(file: path)
    }
    
    func copyBashRC() {
        let path = URL(fileURLWithPath: "/Users/\(self.user)/.bashrc")
        copyArtifact(file: path)
    }
    
    func copyZProfile() {
        let path = URL(fileURLWithPath: "/Users/\(self.user)/.zprofile")
        copyArtifact(file: path)
    }
    
    func copyZshRC() {
        let path = URL(fileURLWithPath: "/Users/\(self.user)/.zshrc")
        copyArtifact(file: path)
    }
    
    func copyZLogin() {
        let path = URL(fileURLWithPath: "/Users/\(self.user)/.zlogin")
        copyArtifact(file: path)
    }
    
    func copyZLogout() {
        let path = URL(fileURLWithPath: "/Users/\(self.user)/.zlogout")
        copyArtifact(file: path)
    }
    
    func run() {
        self.caseHandler.log("Collecting bash history and profile information...")
        copyBashHistory()
        copyZshHistory()
        copyShHistory()
        copyBashProfile()
        copyBashRC()
        copyZProfile()
        copyZshRC()
        copyZLogin()
        copyZLogout()
        self.caseHandler.log("Finished collecting bash history and profile information...")
    }
}
