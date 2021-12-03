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
    
    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        self.artifactsDir = caseHandler.createNewDir(dirName: "artifacts")
        self.tccDir = caseHandler.createNewDir(dirName: "artifacts/tcc_raw")
    }
    
    func start() {
        self.caseHandler.log("Collecting TCC information...")
        let tcc = TCC(caseHandler: caseHandler, artifactsDir: self.artifactsDir, tccDir: self.tccDir)
        tcc.run()

        let lsquarantine = LSQuarantine(caseHandler: caseHandler, artifactsDir: self.artifactsDir)
        lsquarantine.run()
    }
    
}
