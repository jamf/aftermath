//
//  Slack.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

class Slack: FileSystemModule {
    
    let slackLoc: URL
    let writeFile: URL
    
    init(slackLoc: URL, writeFile: URL) {
        self.slackLoc = slackLoc
        self.writeFile = writeFile
    }
    
    func extractSlackPrefs() {
        for user in getBasicUsersOnSystem() {
            var file: URL
            if filemanager.fileExists(atPath: "\(user.homedir)/Library/Containers/com.tinyspeck.slackmacgap/Data/Library/Application Support/Slack/storage/root-state.json") {
                file = URL(fileURLWithPath: "\(user.homedir)/Library/Containers/com.tinyspeck.slackmacgap/Data/Library/Application Support/Slack/storage/root-state.json")
                self.copyFileToCase(fileToCopy: file, toLocation: self.slackLoc, newFileName: "slack_\(user.username)")
            } else { continue }
              
            do {
                let fileContents = try String(contentsOf: file)
                self.addTextToFile(atUrl: self.writeFile, text: fileContents)
            } catch {
                self.log("Unable to parse slack data")
            }
        }
    }
    
    override func run() {
        if Command.disableFeatures["slack"] == false {
            self.log("Collecting Slack information")
            extractSlackPrefs()
        } else {
            self.log("Skipping capturing Slack preferences")
        }
        
    }
}
