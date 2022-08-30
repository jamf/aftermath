//
//  UnifiedLogModule.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class UnifiedLogModule: AftermathModule, AMProto {
    let name = "Unified Log Module"
    let dirName = "UnifiedLog"
    var description = "A module that maintains and runs a list of unified log queries and saves the results"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
    let predicates: [String: String]
    
    override init() {

        self.predicates = [
            "login": "process == \"logind\"",
            "tcc": "process == \"tccd\"",
            "ssh": "process == \"sshd\"",
            "failed_sudo": "process == \"sudo\" and eventMessage CONTAINS \"TTY\" AND eventMessage CONTAINS \"3 incorrect password attempts\"",
            "manual_configuration_profile_install": "subsystem == \"com.apple.ManagedClient\" AND process == \"mdmclient\" AND category == \"MDMDaemon\" and eventMessage CONTAINS \"Installed configuration profile:\" AND eventMessage CONTAINS \"Source: Manual\"",
            "screensharing": "(process == \"screensharingd\" || process == \"ScreensharingAgent\")",
            "xprotect_remediator": "subsystem == \"com.apple.XProtectFramework.PluginAPI\""
        ]
    }
    

    func filterPredicates(filter: [String: String]) {
        for (filtername, filter) in predicates {
            self.log("Filtering for \(filtername) events...")
            
            let command = "log show -info -backtrace -debug -loss -signpost -predicate " + "'" + filter + "'"
            let output = Aftermath.shell("\(command)")

            if output.components(separatedBy: "\n").count > 2 {
                let logfile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "\(filtername).txt")
                self.addTextToFile(atUrl: logfile, text: output)
            } else { continue }
        }
    }
    
    func run() {
        self.log("Filtering Unified Log. Hang Tight!")
        filterPredicates(filter: predicates)
        self.log("Unified Log filtering complete.")
    }
}
