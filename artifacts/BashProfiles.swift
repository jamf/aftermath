//
//  BashProfiles.swift
//  aftermath
//
//

import Foundation


class BashProfiles: ArtifactsModule {
    /// Needs to be modified so that profiles aren't hidden in the directory they're copied to
    /// Needs to be modified so that profiles for all users are collected and not just for the one who ran the script

    let profilesDir: URL
    let user: String
    lazy var writeFile = self.createNewCaseFile(dirUrl: self.moduleDirRoot, filename: "bashProfiles.txt")
    
    init(profilesDir: URL) {
        self.user = NSUserName()
        self.profilesDir = profilesDir
    }
    
    func copyArtifact(file: URL) {
        if (FileManager.default.fileExists(atPath: file.relativePath)) {
            self.copyFileToCase(fileToCopy: file, toLocation: self.profilesDir)
            print("copying \(file) to \(self.profilesDir)")
            self.addTextToFileFromUrl(fromFile: file, toFile: self.writeFile)
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
    
    override func run() {
        self.log("Collecting bash history and profile information...")
        copyBashHistory()
        copyZshHistory()
        copyShHistory()
        copyBashProfile()
        copyBashRC()
        copyZProfile()
        copyZshRC()
        copyZLogin()
        copyZLogout()
        self.log("Finished collecting bash history and profile information...")
    }
}
