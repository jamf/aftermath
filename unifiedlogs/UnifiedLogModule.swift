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
    
    let defaultPredicates: [String: String]
    let logFile: String?
    
    init(logFile: String?) {
        
        self.logFile = logFile
        self.defaultPredicates = [
            "login": "process == \"logind\"",
            "tcc": "process == \"tccd\"",
            "ssh": "process == \"sshd\"",
            "failed_sudo": "process == \"sudo\" and eventMessage CONTAINS \"TTY\" AND eventMessage CONTAINS \"3 incorrect password attempts\"",
            "manual_configuration_profile_install": "subsystem == \"com.apple.ManagedClient\" AND process == \"mdmclient\" AND category == \"MDMDaemon\" and eventMessage CONTAINS \"Installed configuration profile:\" AND eventMessage CONTAINS \"Source: Manual\"",
            "screensharing": "(process == \"screensharingd\" || process == \"ScreensharingAgent\")",
            "xprotect_remediator": "subsystem == \"com.apple.XProtectFramework.PluginAPI\"  && category == \"XPEvent.structured\""
        ]
    }
    

    func filterPredicates(predicates: [String: String]) {
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
    
    func parsePredicateFile(path: String) -> [String: String] {
        self.log("Processing supplied unified log filters...")
        var data = ""
        var inputPredicates: [String : String] = [:]
        
        do {
            data = try String(contentsOfFile: path)
        } catch {
            print(error)
        }
        
        let rows = data.components(separatedBy: "\n")
        
        for row in rows {
            let splitRow = row.split(separator: ":")
            inputPredicates[String(splitRow[0])] = String(splitRow[1])
        }
        
        return inputPredicates
    }
    
    func run() {
        if Command.disableFeatures["ul"] == false {
            self.log("Starting logging unified logs")
            self.log("Filtering Unified Log. Hang Tight!")
            
            // run the external input file of predicates
            if let externalLogFile = self.logFile {
                if !filemanager.fileExists(atPath: externalLogFile) {
                    self.log("No external predicate file found at \(externalLogFile)")
                } else {
                    let externalParsedPredicates = parsePredicateFile(path: externalLogFile)
                    print(externalParsedPredicates)
                    filterPredicates(predicates: externalParsedPredicates)
                }
            }
            
            // run default predicates
            filterPredicates(predicates: self.defaultPredicates)
            self.log("Unified Log filtering complete.")
            
            self.log("Finished logging unified logs")
        } else {
            self.log("Skipping unified logging")
        }

    }
}
