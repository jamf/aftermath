//
//  ProcessModule.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 7/6/22.
//

import Foundation

class ProcessModule: AftermathModule {
    
    let name = "Processes"
    var dirName = "Processes"
    var description = "A module that performs process analysis"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    lazy var rawDir = self.createNewDir(dir: moduleDirRoot, dirname: "raw")
    
    func run() {
        
        let saveFile = self.createNewCaseFile(dirUrl: self.moduleDirRoot, filename: "process.txt")
        
        let tree = Tree()
        
        // Build nodes
        let nodePidDict = tree.createNodeDictionary()

        // Declare a variable for the root node
        
        
        let treeRootNode = tree.buildTrueTree(nodePidDict)
        
        treeRootNode.printTree(saveFile)
        
//        let proc = Pids() // procRawDir: rawDir, saveFile: saveFile
//        proc.run()
    }
}
