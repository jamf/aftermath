//
//  Storyline.swift
//  aftermath
//
//  Copyright 2022 JAMF Software, LLC
//

import Foundation
import SwiftCSV

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
            
            let csvContents = Aftermath.readCSVRows(path: p)
            
            for r in csvContents.rows {
                
                var timestamp: String = ""
                var url: String = ""
                
                for (header, contents) in r {
                    if header == "timestamp" {
                        timestamp = contents
                        continue
                    }
                    if header == "url" {
                        url = contents
                    }
                    
                    if timestamp != "" && url != "" {
                        self.addTextToFile(atUrl: self.storylineFile, text: "\(timestamp),safari_\(title),\(url)")
                    }
                }
            }
        }
    }
    
    func addFirefoxData() {
        
        let chromePaths = ["history":"\(collectionDir)/Browser/Firefox/history_output.csv","downloads":"\(collectionDir)/Browser/Firefox/downloads_output.csv"]
        
        for (title,p) in chromePaths {
            
            if !filemanager.fileExists(atPath: p) { continue }
            
            let csvContents = Aftermath.readCSVRows(path: p)
            
            for r in csvContents.rows {
                
                var timestamp: String = ""
                var url: String = ""
                
                for (header, contents) in r {
                    if header == "datetime" {
                        timestamp = contents
                        continue
                    }
                    if header == "url" {
                        url = contents
                    }
                    
                    if timestamp != "" && url != "" {
                        self.addTextToFile(atUrl: self.storylineFile, text: "\(timestamp),firefox_\(title),\(url)")
                    }
                }
            }
        }
    }
    
    func addChromeData() {
        let chromePaths = ["history":"\(collectionDir)/Browser/Chrome/history_output.csv","downloads":"\(collectionDir)/Browser/Chrome/downloads_output.csv"]
        
        for (title,p) in chromePaths {
            
            if !filemanager.fileExists(atPath: p) { continue }
            
            let csvContents = Aftermath.readCSVRows(path: p)
            
            for r in csvContents.rows {
                
                var timestamp: String = ""
                var url: String = ""
                
                for (header, contents) in r {
                    if header == "datetime" {
                        timestamp = contents
                        continue
                    }
                    if header == "url" {
                        url = contents
                    }
                    
                    if timestamp != "" && url != "" {
                        self.addTextToFile(atUrl: self.storylineFile, text: "\(timestamp),chrome_\(title),\(url)")
                    }
                }
            }
        }
    }
    
    func sortStoryline() {
        
        self.log("Sorting the storyline...")
        
        let sortedStoryline = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "sorted_storyline.csv")
        
        do {
            let csvFile = try EnumeratedCSV(url: self.storylineFile)
            let sortedArr = try Aftermath.sortCSV(unsortedArr: csvFile.rows)
            
            for row in sortedArr {
                let line = row.joined(separator: ",")
                self.addTextToFile(atUrl: sortedStoryline, text: "\(line)")
            }
            self.log("Finished sorting the storyline")
        } catch {
            print(error)
        }
    }

    func run() {
        addSafariData()
        addFirefoxData()
        addChromeData()
        sortStoryline()
    }
}
