//
//  Timeline.swift
//  aftermath
//
//  Copyright 2022 JAMF Software, LLC
//

import Foundation

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
        let metadataFileContents = readMetadataCSVRows(path: metadataPath)
        
        for r in metadataFileContents {
            
            var file: String = ""
            var status: String = ""
            var timestamp: String = ""
            
            if r.file != "" {
                file = r.file
            } else { continue }
            
            if r.birth != "" {
                status = "birth"
                timestamp = r.birth
                self.addTextToFile(atUrl: self.timelineFile, text: "\(timestamp),\(status),\(file)")
                self.addTextToFile(atUrl: self.storylineFile, text: "\(timestamp),\(status),\(file)")
            }
            
            if r.modified != "" {
                status = "modified"
                timestamp = r.modified
                self.addTextToFile(atUrl: self.timelineFile, text: "\(timestamp),\(status),\(file)")
                self.addTextToFile(atUrl: self.storylineFile, text: "\(timestamp),\(status),\(file)")
            }
            
            if r.accessed != "" {
                status = "accessed"
                timestamp = r.accessed
                self.addTextToFile(atUrl: self.timelineFile, text: "\(timestamp),\(status),\(file)")
                self.addTextToFile(atUrl: self.storylineFile, text: "\(timestamp),\(status),\(file)")
            }
        }
    }
    
    func sortTimeline() {
        self.log("Creating a file timeline...")
        
        let sortedTimeline = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "file_timeline.csv")
        
        let metadataFileContents = readTimelineCSVRows(path: self.timelineFile.path)
        
        var unsortedArr: [[String]] = []
        
        for i in metadataFileContents {
            let localArr = [i.timestamp, i.status, i.file]
            unsortedArr.append(localArr)
        }
        
        do {
            let sortedArr = try Aftermath.sortCSV(unsortedArr: unsortedArr)
            
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
    
    func readMetadataCSVRows(path: String) -> [Metadata] {
        var metadata = [Metadata]()
        var data = ""
        
        do {
            data = try String(contentsOfFile: path)
        } catch {
            self.log("Unabler to read metadata csv")
            print(error)
            exit(1)
        }
        
        var rows = data.components(separatedBy: "\n")
        rows.removeFirst()
        
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count == 8 {
                let filePath = columns[0]
                let birth = columns[1]
                let modified = columns[2]
                let accessed = columns[3]
                let permissions = columns[4]
                let uid = columns[5]
                let gid = columns[6]
                let downloadedFrom = columns[7]
                
                let singleEntry = Metadata(file: filePath, birth: birth, modified: modified, accessed: accessed, permissions: permissions, uid: uid, gid: gid, downloadedFrom: downloadedFrom)
                metadata.append(singleEntry)
            }
        }
        return metadata
    }
    
    func readTimelineCSVRows(path: String) -> [TimelineStruct] {
        
        var timelineStruct = [TimelineStruct]()
        var data = ""
        
        do {
            data = try String(contentsOfFile: path)
        } catch {
            print(error)
        }
        
        let rows = data.components(separatedBy: "\n")
        
        for row in rows {
            let columns = row.components(separatedBy: ",")
            if columns.count == 3 {
                let timestamp = columns[0]
                let status = columns[1]
                let file = columns[2]
                
                let singleEntry = TimelineStruct(timestamp: timestamp, status: status, file: file)
                timelineStruct.append(singleEntry)
            }
        }
        return timelineStruct
    }
    
    func run() {
        organizeMetadata() //timestamp, type(download,birth,access,etc), path
        sortTimeline()
        removeUnsorted()
    }
}

struct Metadata {
    var file: String
    var birth: String
    var modified: String
    var accessed: String
    var permissions: String
    var uid: String
    var gid: String
    var downloadedFrom: String
}

struct TimelineStruct {
    var timestamp: String
    var status: String
    var file: String
}
