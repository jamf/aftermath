//
//  ProvenanceTracking.swift
//  aftermath
//
//  Created by Koh Nakagawa on 2023/10/11.
//

import Foundation

@available(macOS 13, *)
class ProvenanceTracking: ArtifactsModule {
    let provenanceDir: URL

    init(provenanceDir: URL) {
        self.provenanceDir = provenanceDir
    }

    func collect() {
        let execPolicy = URL(fileURLWithPath: "/var/db/SystemPolicyConfiguration/ExecPolicy")
        let execPolicyShm = URL(fileURLWithPath: "/var/db/SystemPolicyConfiguration/ExecPolicy-shm")
        let execPolicyWal = URL(fileURLWithPath: "/var/db/SystemPolicyConfiguration/ExecPolicy-wal")

        if (filemanager.fileExists(atPath: execPolicy.path)) {
            self.copyFileToCase(fileToCopy: execPolicy, toLocation: self.provenanceDir)
        }
        if (filemanager.fileExists(atPath: execPolicyShm.path)) {
            self.copyFileToCase(fileToCopy: execPolicyShm, toLocation: self.provenanceDir)
        }
        if (filemanager.fileExists(atPath: execPolicyWal.path)) {
            self.copyFileToCase(fileToCopy: execPolicyWal, toLocation: self.provenanceDir)
        }
    }

    override func run() {
        collect()
    }
}
