//
//  SystemReconModule.swift
//  aftermath
//
//

import Foundation
import AppKit

class SystemReconModule {

    let caseHandler: CaseHandler
    let systemReconDir: URL
    let systemInformationFile: URL
    let installedAppsFile: URL
    let runningAppsFile: URL
    let interfacesFile: URL
    let environmentVariablesFile: URL

    init(caseHandler: CaseHandler) {
        self.caseHandler = caseHandler
        self.systemReconDir = caseHandler.createNewDir(dirName: "systemRecon")
        self.systemInformationFile = caseHandler.createNewCaseFile(dirUrl: self.systemReconDir, filename: "system_information.txt")
        self.installedAppsFile = caseHandler.createNewCaseFile(dirUrl: self.systemReconDir, filename: "installed_apps.txt")
        self.runningAppsFile = caseHandler.createNewCaseFile(dirUrl: self.systemReconDir, filename: "running_apps.txt")
        self.interfacesFile = caseHandler.createNewCaseFile(dirUrl: self.systemReconDir, filename: "interfaces.txt")
        self.environmentVariablesFile = caseHandler.createNewCaseFile(dirUrl: self.systemReconDir, filename: "environment_variables.txt")
    }

    func systemInformation() {
        let hostName = ProcessInfo.processInfo.hostName
        let userName = ProcessInfo.processInfo.userName
        let fullName = ProcessInfo.processInfo.fullUserName
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString

        guard let xprotectVersion = XProtect(key: "Version") else {
            self.caseHandler.log("Error has occured, XProtect returned nil")
            return
        }

        guard let mrtVersion = MRT(key: "CFBundleShortVersionString") else {
            self.caseHandler.log("Error has occured, MRT returned nil")
            return
        }

        self.caseHandler.addTextToFile(atUrl: systemInformationFile, text: "HostName: " + hostName)
        self.caseHandler.addTextToFile(atUrl: systemInformationFile, text: "UserName: " + userName)
        self.caseHandler.addTextToFile(atUrl: systemInformationFile, text: "FullName: " + fullName)
        self.caseHandler.addTextToFile(atUrl: systemInformationFile, text: "System Version: " + systemVersion)
        self.caseHandler.addTextToFile(atUrl: systemInformationFile, text: "XProtect Version: " + xprotectVersion)
        self.caseHandler.addTextToFile(atUrl: systemInformationFile, text: "MRT Version: " + mrtVersion)
    }

    func installedApps() {
        var installAppsArray = [String]()
        let appPath = "/Applications/"
        let fileManager = FileManager.default
        do {
            let appList = try fileManager.contentsOfDirectory(atPath: appPath)
            for app in appList {
                installAppsArray.append(appPath + app)
            }
            self.caseHandler.addTextToFile(atUrl: installedAppsFile, text: installAppsArray.joined(separator: "\n"))
        }
        catch {
            self.caseHandler.log("Error has occured reading directory \(appPath): \(error)")
        }
    }

    func runningApps() {
        var runAppsArray = [String]()
        let applications = NSWorkspace.shared.runningApplications
        for app in applications {
            guard let appUrl: URL = app.executableURL else {
                self.caseHandler.log("Error has occured reading running apps")
                return
            }
            let appString:String = String(describing: appUrl)
            runAppsArray.append(appString)
        }
        self.caseHandler.addTextToFile(atUrl: runningAppsFile, text: runAppsArray.joined(separator: "\n"))
    }

    func interfaces() {
        var interfacesArray = [String]()
        let interfacesDict = Host.current().addresses
        for address in interfacesDict {
            interfacesArray.append(address)
        }
        self.caseHandler.addTextToFile(atUrl: interfacesFile, text: interfacesArray.joined(separator: "\n"))
    }

    func environmentVariables() {
        var envArray = [String]()
        let envDict = ProcessInfo.processInfo.environment
        for variable in envDict {
            envArray.append(variable.value)
        }
        self.caseHandler.addTextToFile(atUrl: environmentVariablesFile, text: envArray.joined(separator: "\n"))
    }

    func XProtect(key: String) -> String? {
        let xprotectPath = "/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Resources/XProtect.meta.plist"

        var xprotectDict: NSDictionary?

        //Load content of XProtect.meta.plist into dictionary
        xprotectDict = NSDictionary(contentsOfFile: xprotectPath)

        if let xprotectDictContent = xprotectDict {
            return "\(xprotectDictContent.object(forKey: key)!)"
        } else {
            self.caseHandler.log("Error has occured reading xprotect plist")
            return nil
        }
    }

    func MRT(key: String) -> String? {
        let mrtPath = "/Library/Apple/System/Library/CoreServices/MRT.app/Contents/version.plist"

        var mrtDict: NSDictionary?

        //Load content of version.plist into dictionary
        mrtDict = NSDictionary(contentsOfFile: mrtPath)

        if let mrtDictContent = mrtDict {
            return "\(mrtDictContent.object(forKey: key)!)"
        } else {
            self.caseHandler.log("Error has occured reading mrt plist")
            return nil
        }
    }

    func start() {
        systemInformation()
        installedApps()
        runningApps()
        interfaces()
        environmentVariables()
    }
}
