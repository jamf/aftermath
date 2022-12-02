//
//  BrowserModule.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation


class BrowserModule: AftermathModule, AMProto {
    let name = "Browser Module"
    var dirName = "Browser"
    var description = "A module that gathers artifacts from different web browsers"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
    
    func run() {
        let edgeDir = self.createNewDir(dir: moduleDirRoot, dirname: "Edge")
        let firefoxDir = self.createNewDir(dir: moduleDirRoot, dirname: "Firefox")
        let chromeDir = self.createNewDir(dir: moduleDirRoot, dirname: "Chrome")
        let safariDir = self.createNewDir(dir: moduleDirRoot, dirname: "Safari")
        let writeFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "browsers.txt")
        
        self.log("Collecting browser information. Make sure browsers are closed to prevent file data from being locked.")
        
        // Check if Edge is installed
        let edge = Edge(edgeDir: edgeDir, writeFile: writeFile)
        edge.run()
        
        // Check if Firefox is installed
        let firefox = Firefox(firefoxDir: firefoxDir, writeFile: writeFile)
        firefox.run()

        // Check if Chrome is installed
        let chrome = Chrome(chromeDir: chromeDir, writeFile: writeFile)
        chrome.run()

        // Check if Safari is installed
        let safari = Safari(safariDir: safariDir, writeFile: writeFile)
        safari.run()
    }
}
