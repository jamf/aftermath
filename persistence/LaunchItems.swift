//
//  LaunchItems.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//
import Foundation


class LaunchItems: PersistenceModule {
    
    let saveToRawDir: URL
    
    init(saveToRawDir: URL) {
        self.saveToRawDir = saveToRawDir
    }
    
    func captureLaunchData(urlLocations: [URL], capturedLaunchFile: URL) {
        for url in urlLocations {
            let plistDict = Aftermath.getPlistAsDict(atUrl: url)
            var binaryName: String = ""
            var binarySHA256: String = ""
            
            // get the progarm key and pass value to parser
            if let binaryLocation = plistDict["Program"] {
                binaryName = (binaryLocation as! String)
                if let binarySHA256 = collectBinaryHashInformation(binaryLocation: binaryName) {
                    self.log("Could not get binarySHA256 for \(binaryName)")
                }
                
            } else if let binaryLocation = plistDict["ProgramArguments"] {
                // grab first element of ProgramArguments
                binaryName = (binaryLocation as! String)
                let arr = binaryLocation as! [String]
                if let binarySHA256 = collectBinaryHashInformation(binaryLocation: arr[0]) {
                    self.log("Could not get binarySHA256 for \(binaryName)")
                }
            } else {
                self.log("Could not get plist information for \(url.relativePath)")
            }
            
            // copy the plists to the persistence directory
            self.copyFileToCase(fileToCopy: url, toLocation: self.saveToRawDir)
            
            // write the plists to one file
            self.addTextToFile(atUrl: capturedLaunchFile, text: "\n----- \(url.path) -----\n")
            self.addTextToFile(atUrl: capturedLaunchFile, text: "Binary Name: \(binaryName)\n")
            self.addTextToFile(atUrl: capturedLaunchFile, text: "Binary SHA256: \(binarySHA256)\n")
            self.addTextToFile(atUrl: capturedLaunchFile, text: plistDict.description)
        }
    }
    
    private func collectBinaryHashInformation(binaryLocation: String)  -> String? { //throws
        if filemanager.fileExists(atPath: binaryLocation) {
            // convert to data
            if let data = filemanager.contents(atPath: binaryLocation) {
                // use extension to get sha256
                let fileHash = data.sha256()
                return fileHash
            }
        } else {
            self.log("Binary does not exist at \(binaryLocation)")
            return nil
        }
        return nil
    }
    
    override func  run() {
        let launchDaemonsPath = "/Library/LaunchDaemons/"
        let launchAgentsPath = "/Library/LaunchAgents/"
        let capturedLaunchFile = self.createNewCaseFile(dirUrl: moduleDirRoot, filename: "launchItems.txt")
        let launchDaemons = filemanager.filesInDirRecursive(path: launchDaemonsPath)
        let launchAgents = filemanager.filesInDirRecursive(path: launchAgentsPath)
        
        self.log("Collecting launchagents and launchdaemons...")
        captureLaunchData(urlLocations: launchDaemons, capturedLaunchFile: capturedLaunchFile)
        captureLaunchData(urlLocations: launchAgents, capturedLaunchFile: capturedLaunchFile)
    }
}
