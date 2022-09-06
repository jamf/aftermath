//
//  Timeline.swift
//  aftermath
//
//  Copyright 2022 JAMF Software, LLC
//

import Foundation
import SwiftCSV

class Timeline: AftermathModule {
    
    let collectionDir: String
    let timelineFile: URL
    let storylineFile: URL
    
    init(collectionDir: String, timelineFile: URL, storylineFile: URL) {
        self.collectionDir = collectionDir
        self.timelineFile = timelineFile
        self.storylineFile = storylineFile
    }
    
    func organizeMetadata() {
        self.log("Parsing metadata...")

        let metadataPath = "\(self.collectionDir)/metadata.csv"
        let metadataFileContents = Aftermath.readCSVRows(path: metadataPath)
        
        let headerOptions = ["birth", "accessed", "modified"]
        
        for r in metadataFileContents.rows {
            
            var file: String = ""
            var timestamp: String = ""
            var status: String = ""
            
            for (header, contents) in r {
                if contents == "unknown" { continue }
                
                if header == "file" {
                    file = contents
                    continue
                }
                
                if headerOptions.contains(header) {
                    status = header
                    timestamp = contents
                }
                
                if file != "" && timestamp != "" && status != "" {
                    self.addTextToFile(atUrl: self.timelineFile, text: "\(timestamp),\(status),\(file)")
                    self.addTextToFile(atUrl: self.storylineFile, text: "\(timestamp),\(status),\(file)")
                    break
                } else { continue }
           
            }
        }
    }
    
    func sortTimeline() {
        self.log("Creating a file timeline...")
        
        let sortedTimeline = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "file_timeline.csv")
        
        do {
            let csvFile = try EnumeratedCSV(url: self.timelineFile)
            let sortedArr = try Aftermath.sortCSV(unsortedArr: csvFile.rows)
            
            for row in sortedArr {
        
                let line = row.joined(separator: ",")
                self.addTextToFile(atUrl: sortedTimeline, text: "\(line)")
            }
            
            self.log("Finished creating the timeline")
        } catch {
            print(error)
        }
    }
    
    func removeUnsorted() {
        do {
            if filemanager.fileExists(atPath: self.timelineFile.path) {
                try filemanager.removeItem(at: self.timelineFile)
            }
        } catch {
            print("Unable to remove unsorted timeline file at \(self.timelineFile.path) due to error\n\(error)")
        }
    }
    
    func run() {
        organizeMetadata() //timestamp, type(download,birth,access,etc), path
        sortTimeline()
        removeUnsorted()
    }
}
