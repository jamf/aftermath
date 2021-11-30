//
//  UnifiedLogModule.swift
//  aftermath
//
//  Created by Benyo on 11/29/21.
//

import Foundation

class UnifiedLogModule {
    
    let caseHandler: CaseHandler
    let predicates: [String: String]
    let unifiedLogDir: URL
    
    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        self.predicates = [
            "login": "process == \"logind\"",
            "tcc": "process == \"tccd\"",
            "ssh": "process == \"sshd\"",
            "failed sudo": "process == \"sudo\" and eventMessage CONTAINS \"TTY\" AND eventMessage CONTAINS \"3 incorrect password attempts\"",
            "manual configuration profile install": "subsystem == \"com.apple.ManagedClient\" AND process == \"mdmclient\" AND category == \"MDMDaemon\" and eventMessage CONTAINS \"Installed configuration profile:\" AND eventMessage CONTAINS \"Source: Manual\"",
            "screensharing": "(process == \"screensharingd\" || process == \"ScreensharingAgent\")"
        ]
        self.unifiedLogDir = caseHandler.createNewDir(dirName: "unifiedLogs")
    }
    
    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
        
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/sh"
        task.launch()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
        
        return output
    }

    func filterPredicates(filter: [String: String]) {
        for (filtername, filter) in predicates {
            self.caseHandler.log("Filtering for \(filtername) events...")
            
            let command = "log show -predicate " + "'" + filter + "'"
            let output = shell("\(command)")

            if output != "" {
                let logfile = self.caseHandler.createNewCaseFile(dirUrl: unifiedLogDir, filename: filtername)
                self.caseHandler.addTextToFile(atUrl: logfile, text: output)
                
                self.caseHandler.log("Done filtering for \(filtername) events")
            } else {
                self.caseHandler.log("No logs found for \(filtername) events")
            }
        }
    }
    
    func start() {
        self.caseHandler.log("Filtering Unified Log. Hang Tight!")
        filterPredicates(filter: predicates)
        self.caseHandler.log("Unified Log filtering complete.")
    }
}
