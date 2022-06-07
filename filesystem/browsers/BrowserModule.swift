//
//  BrowserModule.swift
//  aftermath
//
//

import Foundation


class BrowserModule: AftermathModule, AMProto {
    let name = "Browser Module"
    var dirName = "Browser"
    var description = "A module that gathers artifacts from different web browsers"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)
    
  
    
    func run() {
        let firefoxDir = self.createNewDir(dir: moduleDirRoot, dirname: "Firefox")
        let chromeDir = self.createNewDir(dir: moduleDirRoot, dirname: "Chrome")
        let safariDir = self.createNewDir(dir: moduleDirRoot, dirname: "Safari")
        let writeFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "browsers.txt")
        
        self.log("Collecting browser information...")
        
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

