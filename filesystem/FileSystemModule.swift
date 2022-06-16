//
//  FileSystemModule.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 6/7/22.
//

import Foundation
import AppKit

class FileSystemModule: AftermathModule, AMProto {
    
    let name = "FileSystem"
    var dirName = "FileSystem"
    var description = "A module that performs file system scans"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    lazy var rawDir = self.createNewDir(dir: moduleDirRoot, dirname: "raw")
    
    func run() {
        // run browser module
        let browserModule = BrowserModule()
        browserModule.run()
        
        // get slack data
        let slackFile = self.createNewCaseFile(dirUrl: self.moduleDirRoot, filename: "slack_extract.txt")
        let slack = Slack(slackLoc: self.rawDir, writeFile: slackFile)
        slack.run()
        
    }
    
}
