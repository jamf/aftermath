//
//  ArtifactsModule.swift
//  aftermath
//
//

import Foundation


// tcc
// lsquarantine
// /etc/sudoers
// /etc/host
// /etc/ssh/.*
// ~/.ssh


class ArtifactsModule {
    
    let caseHandler: CaseHandler
    let artifactsDir: URL
    let tccDir: URL
    let sysConfigDir: URL
    let profilesDir: URL
    
    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        self.artifactsDir = caseHandler.createNewDir(dirName: "artifacts")
        self.tccDir = caseHandler.createNewDir(dirName: "artifacts/raw/tcc")
        self.sysConfigDir = caseHandler.createNewDir(dirName: "artifacts/raw/ssh")
        self.profilesDir = caseHandler.createNewDir(dirName: "artifacts/raw/profiles")
    }
    
    func start() {
        let tcc = TCC(caseHandler: caseHandler, artifactsDir: self.artifactsDir, tccDir: self.tccDir)
        tcc.run()

        let lsquarantine = LSQuarantine(caseHandler: caseHandler, artifactsDir: self.artifactsDir)
        lsquarantine.run()
        
        let systemConfig = SystemConfig(caseHandler: caseHandler, artifactsDir: self.artifactsDir, sysConfigDir: self.sysConfigDir)
        systemConfig.run()
        
        let bashProfiles = BashProfiles(caseHandler: caseHandler, artifactsDir: self.artifactsDir, profilesDir: self.profilesDir)
        bashProfiles.run()
    }
}
