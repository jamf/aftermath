//
//  BrowserModule.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation
import AppKit


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
        let arcDir = self.createNewDir(dir: moduleDirRoot, dirname: "Arc")
        let writeFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "browsers.txt")
        
        self.log("Collecting browser information. Make sure browsers are closed to prevent file data from being lost.")
        self.log("Checking for open browsers. Closing any open browsers.")
        
        closeBrowsers()
        
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
        
        // Check if Arc is installed
        let arc = Arc(arcDir: arcDir, writeFile: writeFile)
        arc.run()
    }
    
    func closeBrowsers() {
        let browserData = ["/Applications/Microsoft Edge.app": "com.microsoft.edgemac", "/Applications/Firefox.app": "org.mozilla.firefox", "/Applications/Google Chrome.app": "com.google.Chrome", "/Applications/Safari.app": "com.apple.Safari", "/Applications/Arc.app": "company.thebrowser.Browser"]
        
        for (key, value) in browserData {
            if filemanager.fileExists(atPath: key) {
                for runningApp in NSWorkspace().runningApplications {
                    if runningApp.bundleIdentifier == value {
                        runningApp.forceTerminate()
                    }
                }
            }
        }
    }
}
