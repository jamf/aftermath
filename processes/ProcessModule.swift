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
        if Command.disableFeatures["proc-info"] == false {
            self.log("Starting process dump...")

            let saveFile = self.createNewCaseFile(dirUrl: self.moduleDirRoot, filename: "true_tree_output.txt")
            
            let tree = Tree()
            let nodePidDict = tree.createNodeDictionary()
            let treeRootNode = tree.buildTrueTree(nodePidDict)
            
            treeRootNode.printTree(saveFile)
            
            self.log("Finished gathering process information")

        } else {
            self.log("Skipping process collection")
        }

    }
}
