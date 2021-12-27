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
        let firefoxDir = self.createNewDir(dir: moduleDirRoot, dirname: "firefox")
        let chromeDir = self.createNewDir(dir: moduleDirRoot, dirname: "chrome")
        let safariDir = self.createNewDir(dir: moduleDirRoot, dirname: "safari")
        let operaDir = self.createNewDir(dir: moduleDirRoot, dirname: "opera")
        let braveDir = self.createNewDir(dir: moduleDirRoot, dirname: "brave")
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
        
        // Check if Opera is installed
        let opera = Opera(operaDir: operaDir, writeFile: writeFile)
        opera.run()
        
        // Check if Brave is installed
        let brave = Brave(braveDir: braveDir, writeFile: writeFile)
        brave.run()
    }
}

