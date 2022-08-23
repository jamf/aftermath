//
//  Timeline.swift
//  aftermath
//
//  Created by Stuart Ashenbrenner on 8/10/22.
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
//        self.copyFileToCase(fileToCopy: URL(fileURLWithPath: "\(self.collectionDir)/metadata.csv"), toLocation: CaseFiles.analysisCaseDir, isAnalysis: true)

        let metadataPath = "\(self.collectionDir)/metadata.csv"
        let metadataFileContents = Aftermath.readCSVRows(path: metadataPath)
        
        let headerOptions = ["birth", "accessed", "modified"]
        
        
        for r in metadataFileContents.rows {
            
            var file: String = ""
            var timestamp: String = ""
            var status: String = ""
//            var permissions: String = ""
//            var uid: String = ""
//            var gid: String = ""
//            var downloadedFrom: String = ""
            
            
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
                
//                if header == "permissions" {
//                  permissions = contents
//                    continue
//                }
//
//                if header == "uid" {
//                    uid = contents
//                    continue
//                }
//
//                if header == "gid" {
//                    gid = contents
//                    continue
//                }
//
//                if header == "downloadedFrom" {
//                    downloadedFrom = contents
//                    continue
//                }
                
                
                if file != "" && timestamp != "" && status != "" {
                    self.addTextToFile(atUrl: self.timelineFile, text: "\(timestamp),\(status),\(file)") //,\(permissions),\(uid),\(gid),\(downloadedFrom)
                    self.addTextToFile(atUrl: self.storylineFile, text: "\(timestamp),\(status),\(file)")
                    break
                } else { continue }
           
            }
        }
    }
    
    
    func sortTimeline() {
        
        self.log("Sorting the timeline...")
        
        let sortedTimeline = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "sorted_timeline.csv")
        
        do {
            let csvFile = try EnumeratedCSV(url: self.timelineFile)
            let sortedArr = try Aftermath.sortCSV(unsortedArr: csvFile.rows)
            
            for row in sortedArr {
        
                let line = row.joined(separator: ",")
                self.addTextToFile(atUrl: sortedTimeline, text: "\(line)")
            }
            
            self.log("Finished sorting the timeline")
        } catch {
            print(error)
        }
    }
    
//    func organizeTimeline(unsortedArr: [[String]]) throws -> [[String]] {
//        var arr = unsortedArr
//        try arr.sort { lhs, rhs in
//            guard let lhsStr = lhs.first, let rhsStr = rhs.first else { return false }
//            let lhsDate = try Date("\(lhsStr)Z", strategy: .iso8601)
//            let rhsDate = try Date("\(rhsStr)Z", strategy: .iso8601)
//            return lhsDate > rhsDate
//        }
//        return arr
//    }
    
    
    func run() {
        
        organizeMetadata() //timestamp, type(download,birth,access,etc), path
        sortTimeline()
    }
}
