//
//  ProcessModule.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class ProcessModule: AftermathModule {
    
    let name = "Processes"
    var dirName = "Processes"
    var description = "A module that performs process analysis"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    lazy var rawDir = self.createNewDir(dir: moduleDirRoot, dirname: "raw")
    lazy var processFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "process_dump.txt")
    
    func run() {
        self.log("Starting Process Module")
        let saveFile = self.createNewCaseFile(dirUrl: self.moduleDirRoot, filename: "true_tree_output.txt")
        
        let pc = ProcessCollector()
        let rootNode = pc.getNodeForPid(1)
        guard rootNode != nil else {
            print("Could not find the launchd process. Aborting...")
            exit(1)
        }
        
        //let nodePidDict = tree.createNodeDictionary()
        //let treeRootNode = tree.buildTrueTree(nodePidDict)
        
        // Create a TrueTree
        for proc in pc.processes {
            
            // Create an on the fly node for a plist if one exists
            if let plist = proc.submittedByPlist {
                // Check if this plist is already in the tree
                if let existingPlistNode = rootNode?.searchPlist(value: plist) {
                    existingPlistNode.add(child: proc.node)
                    continue
                }
                
                let plistNode = Node(-1, path: plist, timestamp: "00:00:00", source: "launchd_xpc", displayString: plist)
                rootNode?.add(child: plistNode)
                plistNode.add(child: proc.node)
                continue
            }
            
            // Otherwise add the process as a child to its true parent
            let parentNode = pc.getNodeForPid(proc.trueParentPid)
            parentNode?.add(child: proc.node)
            
            // Create an on the fly node for any network connections this pid has and add them to itself
            for x in proc.network {
                if let type = x.type {
                    var displayString = ""
                    if type == "TCP" {
                        displayString = "\(type) - \(x.source):\(x.sourcePort) -> \(x.destination):\(x.destinationPort) - \(x.status)"
                    } else {
                        displayString = "\(type) - Local Port: \(x.sourcePort)"
                    }
                    
                    let networkNode = Node(-1, path: "none", timestamp: "00:00:00", source: "Network", displayString: displayString)
                    proc.node.add(child: networkNode)
                }
            }
        }
        
        rootNode?.printTree(toFile: saveFile)
        
        self.log("Finished Process Module")
    }
    
}
