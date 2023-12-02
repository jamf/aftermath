//
//  BashProfiles.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation


class BashProfiles: ArtifactsModule {
    let profilesDir: URL
    
    init(profilesDir: URL) {
        self.profilesDir = profilesDir
    }
    
    
    override func run() {
        self.log("Collecting shell history and profile information...")
        
        let userFiles = [ ".bash_history", ".bash_profile", ".bashrc", ".bash_logout",
                          ".zsh_history", ".zshenv", ".zprofile", ".zshrc", ".zlogin", ".zlogout",
                          ".sh_history", ".config/fish/config.fish"
        ]
        
        let globalFiles = ["/etc/profile", "/etc/zshenv", "/etc/zprofile", "/etc/zshrc", "/etc/zlogin", "/etc/zlogout"]
        
        // for each user, copy the shell historys and profiles
        for user in getUsersOnSystem() {
            for filename in userFiles {
                let path = URL(fileURLWithPath: "\(user.homedir)/\(filename)")
                if (filemanager.fileExists(atPath: path.path)) {
                    let newFileName = "\(user.username)_\(filename.replacingOccurrences(of: "/", with: ""))"
                    self.copyFileToCase(fileToCopy: path, toLocation: self.profilesDir, newFileName: newFileName)
                }
               
            }
        }

        
        // Copy all the global files
        for file in globalFiles {
            let fileUrl = URL(fileURLWithPath: file)
            if (filemanager.fileExists(atPath: fileUrl.path)) {
                let filename = fileUrl.lastPathComponent
                let newFileName = "etc_\(filename)"
                self.copyFileToCase(fileToCopy: fileUrl, toLocation: self.profilesDir, newFileName: newFileName)
            }
        }
        
        
        self.log("Finished collecting shell history and profile information...")
    }
}
