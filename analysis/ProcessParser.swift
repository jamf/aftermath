//
//  ProcessParser.swift
//  aftermath
//
//  Copyright 2022 JAMF Software, LLC
//

import Foundation

class ProcessParser: AftermathModule {
    
    let collectionDir: String
    let storylineFile: URL
    
    init(collectionDir: String, storylineFile: URL) {
        self.collectionDir = collectionDir
        self.storylineFile = storylineFile
    }
    
    func parseProcessDump() {
     
        let procPathRaw = "\(self.collectionDir)/Processes/process_dump.txt"
        if filemanager.fileExists(atPath: procPathRaw) {
            do {
                
                let data = try String(contentsOf: URL(fileURLWithPath: procPathRaw), encoding: .utf8)
                let line = data.components(separatedBy: "\n")
                
                for ind in 1...line.count - 1 {
                    let splitLine = line[ind].components(separatedBy: " ")
                    
                    guard let date = splitLine[safe: 0] else { continue }
                    guard let time = splitLine[safe: 1] else { continue }
                    guard let zone = splitLine[safe: 2] else { continue }
                    let unformattedDate = date + "T" + time + zone // 2022-09-02T17:16:58 +0000
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US")
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // 2022-09-02T17:16:58+0000
                    dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                    
                    var info = ""
                    for i in 3...splitLine.count - 1 {
                        info = info.appending(" " + splitLine[i])
                    }
                    
                    sanatizeInfo(&info)
                    
                    guard let dateZone = dateFormatter.date(from: unformattedDate) else { continue }
                    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                    let formattedDate = dateFormatter.string(from: dateZone)
                    let text = "\(formattedDate), PROCESS, \(info)"
                    self.addTextToFile(atUrl: self.storylineFile, text: text)
                }
            } catch {
                print("Error parsing process dump raw file: \(error)")
            }
        } else {
            self.log("Process data not available")
        }
    }
        
    
    fileprivate func sanatizeInfo(_ info: inout String) {
        info = info.replacingOccurrences(of: ",", with: "")
        info = info.replacingOccurrences(of: "\"", with: "")
    }
    
    func run() {
        self.log("Parsing process collection...")
        parseProcessDump()
    }
}
