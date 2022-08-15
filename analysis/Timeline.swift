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
    
    init(collectionDir: String, timelineFile: URL) {
        self.collectionDir = collectionDir
        self.timelineFile = timelineFile
    }
    
    func organizeMetadata() {
        self.log("Parsing metadata...")
        self.copyFileToCase(fileToCopy: URL(fileURLWithPath: "\(self.collectionDir)/metadata.csv"), toLocation: CaseFiles.analysisCaseDir, isAnalysis: true)

        let metadataPath = "\(CaseFiles.analysisCaseDir.path)/metadata.csv"
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
                }
            }
        }
    }
    
    
    func sortTimeline() {
        
        self.log("Sorting the timeline...")
        
        var result: [[String]] = []
        let sortedTimeline = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "sorted_timeline.csv")
        
        do {
            let csvFile = try EnumeratedCSV(url: self.timelineFile)
            
            let sortedArr = try organizeTimeline(unsortedArr: csvFile.rows)
            
            var writeOut: String = ""
            
            for r in sortedArr {
//                print(r)
                
                for i in r {
//                    print(i)
                    writeOut += "\(i),"
                }
        
//                self.addTextToFile(atUrl: sortedTimeline, text: "\(writeOut)")
//                let _ = try writeOut.write(toFile: self.timelineFile.path, atomically: true, encoding: .utf8)
//                print(writeOut)
            }
            
            
//            print(result)
        } catch {
            print(error)
        }
        
        self.log("Finished sorting the timeline")
//        let unsortedTimeline = Aftermath.readCSVRows(path: self.timelineFile.path)
//        print("arrived")
        

        
    }
    
    func organizeTimeline(unsortedArr: [[String]]) throws -> [[String]] {
        var arr = unsortedArr
        try arr.sort { lhs, rhs in
            guard let lhsStr = lhs.first, let rhsStr = rhs.first else { return false }
            let lhsDate = try Date("\(lhsStr)Z", strategy: .iso8601)
            let rhsDate = try Date("\(rhsStr)Z", strategy: .iso8601)
//            print()
//            print(lhsDate)
//            print(rhsDate)
//            print(lhsDate > rhsDate)
//            print()
            return lhsDate > rhsDate
        }
        return arr
    }
    
    
    func run() {
        
        organizeMetadata()
        sortTimeline()
    }
    
}
