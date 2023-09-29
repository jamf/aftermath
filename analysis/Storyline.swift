//
//  Storyline.swift
//  aftermath
//
//  Copyright 2022 JAMF Software, LLC
//

import Foundation

@available(macOS 12.0, *)
class Storyline: AftermathModule {
    
    let collectionDir: String
    let storylineFile: URL
    let timelineFile: URL
    
    init(collectionDir: String, storylineFile: URL, timelineFile: URL) {
        self.collectionDir = collectionDir
        self.storylineFile = storylineFile
        self.timelineFile = timelineFile
    }
    
    func addSafariData() {
        let safariPaths = ["history":"\(collectionDir)/Browser/Safari/history_output.csv","downloads":"\(collectionDir)/Browser/Safari/downloads_output.csv"]
        
        for (title,p) in safariPaths {
            
            if !filemanager.fileExists(atPath: p) { continue }
            
            var data = ""
            
            do {
                data = try String(contentsOfFile: p)
            } catch {
                print(error)
            }
            
            var rows = data.components(separatedBy: "\n")
            rows.removeFirst()
            
            for row in rows {
                if row == "" { continue }
                let columns = row.components(separatedBy: ",")
                self.addTextToFile(atUrl: self.storylineFile, text: "\(columns[0]),safari_\(title),\(columns[1]))")
            }
        }
        addSafariNotificationsData()
    }
    
    private func addSafariNotificationsData() {
        
        let notificationsPath = "\(collectionDir)/Browser/Safari/safari_notifications.csv"
        
        if !filemanager.fileExists(atPath: notificationsPath) { return }
        
        var data = ""
        
        do {
            data = try String(contentsOfFile: notificationsPath)
        } catch {
            print(error)
        }
        
        var rows = data.components(separatedBy: "\n")
        rows.removeFirst()
        
        for row in rows {
            if row == "" { continue }
            let columns = row.components(separatedBy: ",")
            self.addTextToFile(atUrl: self.storylineFile, text: "\(columns[0]),safari_notification,\(columns[1]),\(columns[2])")
        }
    }
    
    func addFirefoxData() {
        let firefoxPaths = ["history":"\(collectionDir)/Browser/Firefox/history_output.csv","downloads":"\(collectionDir)/Browser/Firefox/downloads_output.csv"]
        
        for (title,p) in firefoxPaths {
            
            if !filemanager.fileExists(atPath: p) { continue }
            
            var data = ""
            
            do {
                data = try String(contentsOfFile: p)
            } catch {
                print(error)
            }
            
            var rows = data.components(separatedBy: "\n")
            rows.removeFirst()
            for row in rows {
                if row == "" { continue }
                let columns = row.components(separatedBy: ",")
                self.addTextToFile(atUrl: self.storylineFile, text: "\(columns[0]),firefox_\(title),\(columns[1]))")
            }
        }
    }
    
    func addChromeData() {
        let chromePaths = ["history":"\(collectionDir)/Browser/Chrome/history_output.csv","downloads":"\(collectionDir)/Browser/Chrome/downloads_output.csv"]
        
        for (title,p) in chromePaths {
            
            if !filemanager.fileExists(atPath: p) { continue }
            
            var data = ""
            
            do {
                data = try String(contentsOfFile: p)
            } catch {
                print(error)
            }
            
            var rows = data.components(separatedBy: "\n")
            rows.removeFirst()
            for row in rows {
                if row == "" { continue }
                let columns = row.components(separatedBy: ",")
                self.addTextToFile(atUrl: self.storylineFile, text: "\(columns[0]),chrome_\(title),\(columns[3]))")
            }
        }
    }
    
    func addEdgeData() {
        let edgePaths = ["history":"\(collectionDir)/Browser/Edge/history_output.csv","downloads":"\(collectionDir)/Browser/Edge/downloads_output.csv"]
        
        for (title,p) in edgePaths {
            
            if !filemanager.fileExists(atPath: p) { continue }
                        
            var data = ""
            
            do {
                data = try String(contentsOfFile: p)
            } catch {
                print(error)
            }
            
            var rows = data.components(separatedBy: "\n")
            rows.removeFirst()
            for row in rows {
                if row == "" { continue }
                let columns = row.components(separatedBy: ",")
                self.addTextToFile(atUrl: self.storylineFile, text: "\(columns[0]),edge_\(title),\(columns[3]))")
            }
        }
    }
    
    func addArcData() {
        let arcPaths = ["history":"\(collectionDir)/Browser/Arc/history_output.csv","downloads":"\(collectionDir)/Browser/Arc/downloads_output.csv"]
        
        for (title,p) in arcPaths {
            
            if !filemanager.fileExists(atPath: p) { continue }
            
            var data = ""
            
            do {
                data = try String(contentsOfFile: p)
            } catch {
                print(error)
            }
            
            var rows = data.components(separatedBy: "\n")
            rows.removeFirst()
            for row in rows {
                if row == "" { continue }
                let columns = row.components(separatedBy: ",")
                self.addTextToFile(atUrl: self.storylineFile, text: "\(columns[0]),arc_\(title),\(columns[3]))")
            }
        }
    }
    
    func addBraveData() {
        let bravePaths = ["history":"\(collectionDir)/Browser/Brave/history_output.csv","downloads":"\(collectionDir)/Browser/Brave/downloads_output.csv"]
        
        for (title,p) in bravePaths {
            
            if !filemanager.fileExists(atPath: p) { continue }
            
            var data = ""
            
            do {
                data = try String(contentsOfFile: p)
            } catch {
                print(error)
            }
            
            var rows = data.components(separatedBy: "\n")
            rows.removeFirst()
            for row in rows {
                if row == "" { continue }
                let columns = row.components(separatedBy: ",")
                self.addTextToFile(atUrl: self.storylineFile, text: "\(columns[0]),brave_\(title),\(columns[3]))")
            }
        }
    }
    
    func sortStoryline() {
        
        self.log("Creating the storyline...Please wait...")
        
        let sortedStoryline = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "storyline.csv")
        let csvFileContents = readStorylineCSV(path: self.storylineFile.path)
        var unsortedArr: [[String]] = []
        
        for i in csvFileContents {
            let localArr = [i.timestamp, i.type, i.other, i.path]
            unsortedArr.append(localArr)
        }
        
        do {
            let sortedArr = try Aftermath.sortCSV(unsortedArr: unsortedArr)
            
            for row in sortedArr {
                let line = row.joined(separator: ",")
                self.addTextToFile(atUrl: sortedStoryline, text: "\(line)")
            }
            
            self.log("Finished creating the storyline")
        } catch {
            self.log("Error creating the storyline")
            print(error)
        }
    }
    
    private func readStorylineCSV(path: String) -> [StorylineStruct] {
       
        var storylineStruct = [StorylineStruct]()
        var data = ""
        
        do {
            data = try String(contentsOfFile: path)
        } catch {
            print(error)
        }
        
        var rows = data.components(separatedBy: "\n")
        rows.removeFirst() // headers - ["timestamp", "type", "other", "path"]
        
        for row in rows {
            if row == "" { continue }
            let columns = row.components(separatedBy: ",")

            let timestamp = columns[0]
            let type = columns[1]
            let other = columns[2]
            var path = ""
            if columns.count == 4 {
                path = columns[3]
            }
                
            let singleEntry = StorylineStruct(timestamp: timestamp, type: type, other: other, path: path)
            storylineStruct.append(singleEntry)
        }
        return storylineStruct
    }
    
    func removeUnsorted() {
        
        do {
            if filemanager.fileExists(atPath: self.storylineFile.path) {
                try filemanager.removeItem(at: self.storylineFile)
            }
        } catch {
            print("Unable to remove unsorted timeline file at \(self.storylineFile.path) due to error\n\(error)")
        }
    }

    func run() {
        addSafariData()
        addFirefoxData()
        addChromeData()
        addEdgeData()
        addArcData()
        addBraveData()
        sortStoryline()
        removeUnsorted()
    }
}

struct StorylineStruct {
    var timestamp: String
    var type: String
    var other: String
    var path: String
}
