//
//  UnifiedLogModule.swift
//  aftermath
//
//

import Foundation

class UnifiedLogModule {
    
    let caseHandler: CaseHandler
    let predicates: [String: String]
    let unifiedLogDir: URL
    
    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        //predicates eventually to be loaded from external file
        self.predicates = [
            "login": "process == \"logind\"",
            "tcc": "process == \"tccd\"",
            "ssh": "process == \"sshd\"",
            "failed_sudo": "process == \"sudo\" and eventMessage CONTAINS \"TTY\" AND eventMessage CONTAINS \"3 incorrect password attempts\"",
            "manual_configuration_profile_install": "subsystem == \"com.apple.ManagedClient\" AND process == \"mdmclient\" AND category == \"MDMDaemon\" and eventMessage CONTAINS \"Installed configuration profile:\" AND eventMessage CONTAINS \"Source: Manual\"",
            "screensharing": "(process == \"screensharingd\" || process == \"ScreensharingAgent\")"
        ]
        self.unifiedLogDir = caseHandler.createNewDir(dirName: "unifiedLogs")
    }
    

    func filterPredicates(filter: [String: String]) {
        for (filtername, filter) in predicates {
            self.caseHandler.log("Filtering for \(filtername) events...")
            
            let command = "log show -info -backtrace -debug -loss -signpost -predicate " + "'" + filter + "'"
            let output = Aftermath.shell("\(command)")

            if output != "" {
                let logfile = self.caseHandler.createNewCaseFile(dirUrl: unifiedLogDir, filename: filtername)
                self.caseHandler.addTextToFile(atUrl: logfile, text: output)
                
                //self.caseHandler.log(module: self.moduleName, "Done filtering for \(filtername) events")
            } else {
                //self.caseHandler.log(module: self.moduleName, "No logs found for \(filtername) events")
            }
        }
    }
    
    func start() {
        self.caseHandler.log("Filtering Unified Log. Hang Tight!")
        filterPredicates(filter: predicates)
        self.caseHandler.log("Unified Log filtering complete.")
    }
}
