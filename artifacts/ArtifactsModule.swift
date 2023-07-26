//
//  ArtifactsModule.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class ArtifactsModule: AftermathModule, AMProto {
    
    let name = "Artifacts Module"
    var dirName = "Artifacts"
    var description = "A module that collections various artifacts stored on disk"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
    func run() {
        let rawDir = self.createNewDir(dir: moduleDirRoot, dirname: "raw")
        let systemConfigDir = self.createNewDir(dir: rawDir, dirname: "ssh")
        let profilesDir = self.createNewDir(dir: rawDir, dirname: "profiles")
        let logFilesDir = self.createNewDir(dir: rawDir, dirname: "logs")
        let xbsDir = self.createNewDir(dir: rawDir, dirname: "xbs")
        
        let tcc = TCC(tccDir: rawDir)
        tcc.run()

        let lsquarantine = LSQuarantine(rawDir: rawDir)
        lsquarantine.run()
        
        let systemConf = SystemConfig(systemConfigDir: systemConfigDir)
        systemConf.run()
        
        let bashProfiles = BashProfiles(profilesDir: profilesDir)
        bashProfiles.run()
        
        let logFiles = LogFiles(logFilesDir: logFilesDir)
        logFiles.run()
        
        let configProfiles = ConfigurationProfiles()
        configProfiles.run()
        
        if #available(macOS 13, *) {
            self.log("Collecting the XPdb")
            let xbs = XProtectBehavioralService(xbsDir: xbsDir)
            xbs.run()
        } else {
            self.log("Unable to capture XPdb due to unavailability on this OS")
        }
    }
}
