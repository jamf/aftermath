//
//  BrowserModule.swift
//  aftermath
//
//

import Foundation

class BrowserModule {
    
    let caseHandler: CaseHandler
    let browserDir: URL
    let firefox: URL
    let chrome: URL
    let safari: URL
    let opera: URL
    let brave: URL
    let writeFile: URL
    
    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        self.browserDir = caseHandler.createNewDir(dirName: "browsers")
        self.firefox = caseHandler.createNewDir(dirName: "browsers/firefox")
        self.chrome = caseHandler.createNewDir(dirName: "browsers/chrome")
        self.safari = caseHandler.createNewDir(dirName: "browsers/safari")
        self.opera = caseHandler.createNewDir(dirName: "browsers/opera")
        self.brave = caseHandler.createNewDir(dirName: "browsers/brave")
        
        self.writeFile = caseHandler.createNewCaseFile(dirUrl: browserDir, filename: "browsers.txt")
    }
    
    func start() {
        self.caseHandler.log("Collecting browser information...")
        
        // Check if Firefox is installed
        if aftermath.systemReconModule.installAppsArray.contains(Browsers.firefox.rawValue) {
            let firefox = Firefox(caseHandler: caseHandler, browserDir: self.browserDir, firefoxDir: self.firefox, writeFile: self.writeFile, appPath: Browsers.firefox.rawValue)
            firefox.run()
        } else {
            self.caseHandler.log("Firefox not installed. Continuing browser recon...")
        }
        
        // Check if Chrome is installed
        if aftermath.systemReconModule.installAppsArray.contains(Browsers.chrome.rawValue) {
            let chrome = Chrome(caseHandler: caseHandler, browserDir: self.browserDir, chromeDir: self.chrome, writeFile: self.writeFile, appPath: Browsers.chrome.rawValue)
            chrome.run()
        } else {
            self.caseHandler.log("Chrome not installed. Continuing browser recon...")
        }
        
        // Check if Safari is installed
        if aftermath.systemReconModule.installAppsArray.contains(Browsers.safari.rawValue) {
            let safari = Safari(caseHandler: caseHandler, browserDir: self.browserDir, safariDir: self.safari, writeFile: self.writeFile, appPath: Browsers.safari.rawValue)
            safari.run()
        } else {
            self.caseHandler.log("Safari not installed. Continuing browser recon...")
        }
        
        // Check if Opera is installed
        if aftermath.systemReconModule.installAppsArray.contains(Browsers.opera.rawValue) {
            let opera = Opera(caseHandler: caseHandler, browserDir: self.browserDir, operaDir: self.opera, writeFile: self.writeFile, appPath: Browsers.opera.rawValue)
            opera.run()
        } else {
            self.caseHandler.log("Opera not installed. Continuing browser recon...")
        }
        
        // Check if Brave is installed
        if aftermath.systemReconModule.installAppsArray.contains(Browsers.brave.rawValue) {
            let brave = Brave(caseHandler: caseHandler, browserDir: self.browserDir, braveDir: self.brave, writeFile: self.writeFile, appPath: Browsers.brave.rawValue)
            brave.run()
        } else {
            self.caseHandler.log("Brave Browser not installed. Continuing browser recon...")
        }
    }
    
    enum Browsers: String, CaseIterable {
        case firefox = "/Applications/Firefox.app"
        case chrome = "/Applications/Google Chrome.app"
        case safari = "/Applications/Safari.app"
        case opera = "/Applications/Opera.app"
        case brave = "/Applications/Brave Browser.app"
    }
}
