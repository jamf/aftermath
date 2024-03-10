//
//  SystemReconModule.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation
import AppKit


class SystemReconModule: AftermathModule, AMProto {
    let name = "System Recon"
    var dirName = "Recon"
    var description = "A module that performs scans of the system to gain helpful information about installed applications"
    lazy var moduleDirRoot = self.createNewDirInRoot(dirName: dirName)

    func systemInformation(saveFile: URL) {
        let hostName = ProcessInfo.processInfo.hostName
        let userName = ProcessInfo.processInfo.userName
        let fullName = ProcessInfo.processInfo.fullUserName
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersionString

        guard let xprotectVersion = XProtect(key: "Version") else {
            self.log("Error has occured, XProtect returned nil")
            return
        }

        guard let mrtVersion = MRT(key: "CFBundleShortVersionString") else {
            self.log("Error has occured, MRT returned nil")
            return
        }
        
        guard let xprotectRemediatorVersion = XProtectRemediator(key: "CFBundleShortVersionString") else {
            self.log("Error has occured, XProtect Remediator returned nil")
            return
        }

        self.addTextToFile(atUrl: saveFile, text: "HostName: \(hostName)\nUserName: \(userName)\nFullName: \(fullName)\nSystem Version: \(systemVersion)\nXProtect Version: \(xprotectVersion)\nXProtect Remediator Version: \(xprotectRemediatorVersion)\nMRT Version: \(mrtVersion)")
        self.addTextToFile(atUrl: saveFile, text: "\n----------\n")
    }

    func installedApps(saveFile: URL) {
        let appPath = "/Applications/"
        
        var installAppsArray = [String]()
        do {
            let appList = try filemanager.contentsOfDirectory(atPath: appPath)
            for app in appList {
                installAppsArray.append(appPath + app)
            }
            self.addTextToFile(atUrl: saveFile, text: installAppsArray.joined(separator: "\n"))
        }
        catch {
            self.log("Error has occured reading directory \(appPath): \(error)")
        }
    }
    
    func installHistory(saveFile: URL) {
        let installPath = "/Library/Receipts/InstallHistory.plist"
        
        self.addTextToFile(atUrl: saveFile, text: "ProcessName,Datetime,ContentType,DisplayName,DisplayVersion,PackageIdentifers")
        
        let data = filemanager.contents(atPath: installPath)
        let installDict = try! PropertyListSerialization.propertyList(from: data!, options: [], format: nil) as! Array<[String: Any]>

        var date:String = ""
        var contentType:String = ""
        var displayName:String = ""
        var displayVersion:String = ""
        var packageIdentifiers:Array<String> = []
        var processName:String = ""
        
        for data in installDict {
            let dateFormatter = DateFormatter()
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"

            
            if data["processName"] != nil {
                processName = data["processName"]! as! String
            } else {
                processName = "unknown"
            }
            
            if data["date"] != nil {
                date = dateFormatter.string(from: data["date"]! as! Date)
            } else {
                date = "unknown"
            }
            
            if data["contentType"] != nil {
                contentType = data["contentType"]! as! String
            } else {
                contentType = "unknown"
            }
            
            if data["displayName"] != nil {
                displayName = data["displayName"]! as! String
            } else {
                displayName = "unknown"
            }
            
            if data["displayVersion"] != nil {
                displayVersion = data["displayVersion"]! as! String
            } else {
                displayVersion = "unknown"
            }
            
            if data["packageIdentifiers"] != nil {
                packageIdentifiers = data["packageIdentifiers"]! as! Array<String>

            } else {
                packageIdentifiers = ["unknown"]
            }
            self.addTextToFile(atUrl: saveFile, text: "\(processName),\(date),\(contentType),\(displayName),\(displayVersion),\(packageIdentifiers.joined(separator: ","))")

        }
    }

    func runningApps(saveFile: URL) {
        var runAppsArray = [String]()
        let applications = NSWorkspace.shared.runningApplications
        for app in applications {
            guard let appUrl: URL = app.executableURL else {
                self.log("Error has occured reading running apps")
                return
            }
            let appString:String = String(describing: appUrl.path)
            runAppsArray.append(appString)
        }
        self.addTextToFile(atUrl: saveFile, text: runAppsArray.joined(separator: "\n"))
    }

    func interfaces(saveFile: URL) {
        var interfacesArray = [String]()
        let interfacesDict = Host.current().addresses
        for address in interfacesDict {
            interfacesArray.append(address)
        }
        self.addTextToFile(atUrl: saveFile, text: interfacesArray.joined(separator: "\n"))
    }

    func environmentVariables(saveFile: URL) {
        var envArray = [String]()
        let envDict = ProcessInfo.processInfo.environment
        for variable in envDict {
            envArray.append(variable.value)
        }
        self.addTextToFile(atUrl: saveFile, text: envArray.joined(separator: "\n"))
    }

    func XProtect(key: String) -> String? {
        let xprotectPath = URL(fileURLWithPath: "/Library/Apple/System/Library/CoreServices/XProtect.bundle/Contents/Resources/XProtect.meta.plist")
        
        let xprotectDict = Aftermath.getPlistAsDict(atUrl: xprotectPath)
        
        if let xprotectKeyValue = xprotectDict[key] {
            return String(describing:xprotectKeyValue)
        } else {
            self.log("Error has occured reading xprotect plist")
            return nil
        }
    }

    func MRT(key: String) -> String? {
        let mrtPath = URL(fileURLWithPath: "/Library/Apple/System/Library/CoreServices/MRT.app/Contents/version.plist")

        let mrtDict = Aftermath.getPlistAsDict(atUrl: mrtPath)
        
        if let mrtKeyValue = mrtDict[key] {
            return String(describing:mrtKeyValue)
        } else {
            self.log("Error has occured reading mrt plist")
            return nil
        }
    }

    func XProtectRemediator(key: String) -> String? {
        let xprotectRemediatorPath = URL(fileURLWithPath: "/Library/Apple/System/Library/CoreServices/XProtect.app/Contents/version.plist")

        let xprotectRemediatorDict = Aftermath.getPlistAsDict(atUrl: xprotectRemediatorPath)
        
        if let xprotectRemKeyValue = xprotectRemediatorDict[key] {
            return String(describing:xprotectRemKeyValue)
        } else {
            self.log("Error has occured reading xprotect remediator plist")
            return nil
        }
    }
    
    func securityAssessment(saveFile: URL) {
        let dict = ["Gatekeeper Status": "spctl --status",
                    "SIP Status": "csrutil status",
                    "Screen Sharing": "sudo launchctl list com.apple.screensharing",
                    "Firewall Status (Enabled = 1, Disabled = 0)": "defaults read /Library/Preferences/com.apple.alf globalstate",
                    "Filevault Status": "sudo fdesetup status",
                    "Airdrop Status": "sudo ifconfig awdl0 | awk '/status/{print $2}'",
                    "Remote Login": "sudo systemsetup -getremotelogin",
                    "Network File Shares": "nfsd status",
                    "I/O Statistics": "iostat",
                    "Login History": "last",
                    "Network Interface Parameters": "ifconfig"
        ]
        
        for (heading,command) in dict {
            let output = Aftermath.shell("\(command)")
            
            self.addTextToFile(atUrl: saveFile, text: "\n\(heading):\n\(output)")
        }
    }
    
    func installedUsers(saveFile: URL) {
        self.addTextToFile(atUrl: saveFile, text: "Users:\n")

        for user in getUsersOnSystem() {
            self.addTextToFile(atUrl: saveFile, text: "\(user.username)\n\(user.homedir)\n\n")
        }
        
        let passwdWriteFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "etc_passwd.txt")
        do {
            let etcContents = try String(contentsOfFile: "/etc/passwd")
            self.addTextToFile(atUrl: passwdWriteFile, text: "\(etcContents)")
        } catch {
            print(error)
        }
    }

    func run() {
        self.log("Started system recon")

        let systemInformationFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "system_information.txt")
        let installedAppsFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "installed_apps.txt")
        let runningAppsFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "running_apps.txt")
        let interfacesFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "interfaces.txt")
        let environmentVariablesFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "environment_variables.txt")
        let installHistoryFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "install_history.csv")
        let installedUsersFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "users.txt")
        
        systemInformation(saveFile: systemInformationFile)
        installedApps(saveFile: installedAppsFile)
        runningApps(saveFile: runningAppsFile)
        installHistory(saveFile: installHistoryFile)
        interfaces(saveFile: interfacesFile)
        environmentVariables(saveFile: environmentVariablesFile)
        securityAssessment(saveFile: systemInformationFile)
        installedUsers(saveFile: installedUsersFile)
        
        self.log("Finished system recon")

    }
}
