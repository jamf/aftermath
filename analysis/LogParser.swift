//
//  LogParser.swift
//  aftermath
//
//  Copyright 2022 JAMF Software, LLC
//

import Foundation

@available(macOS 12, *)
class LogParser: AftermathModule {
    
    lazy var logsFile = self.createNewCaseFile(dirUrl: CaseFiles.analysisCaseDir, filename: "logs.csv")
    let collectionDir: String
    let storylineFile: URL
    
    init(collectionDir: String, storylineFile: URL) {
        self.collectionDir = collectionDir
        self.storylineFile = storylineFile
    }
    
    func parseInstallLog() {
        // install.log
        
        let installLog = "\(collectionDir)/Artifacts/raw/logs/system_logs/install.log"
        do {
            let contents = try String(contentsOf: URL(fileURLWithPath: installLog))
            let installLogContents = contents.components(separatedBy: "\n")
            
            for ind in 0...installLogContents.count - 1 {
                
                let splitLine = installLogContents[ind].components(separatedBy: " ")
                
                guard let date = splitLine[safe: 0] else { continue }
                guard let time = splitLine[safe: 1] else { continue }
                let unformattedDate = date + "T" + time // ex: 2022-03-15T16:22:55-07
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                var info = ""
                
                for i in 0...splitLine.count - 1 {
                    if i == 0 || i == 1  { continue }
                    info = info.appending(" " + splitLine[i])
                }
                
                sanatizeInfo(&info)
                
                guard let dateZone = dateFormatter.date(from: unformattedDate) else { continue }
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                let formattedDate = dateFormatter.string(from: dateZone)
                let text = "\(formattedDate), INSTALL, \(info)"
                self.addTextToFile(atUrl: logsFile, text: text)
                self.addTextToFile(atUrl: self.storylineFile, text: text)
            }
        } catch {
            self.log("Unable to parse install log contents")
        }
    }

    func parseSysLog() {
        // system.log
        
        let systemLog = "\(collectionDir)/Artifacts/raw/logs/system_logs/system.log"
        
        do {
            let contents = try String(contentsOf: URL(fileURLWithPath: systemLog))
            let systemLogConetnts = contents.components(separatedBy: "\n")
            
            for ind in 0...systemLogConetnts.count - 1 {
                
                let splitLine = systemLogConetnts[ind].components(separatedBy: " ")
               
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.dateFormat = "MMM dd yyyy HH:mm:ss"
                dateFormatter.timeZone = .current
                
                let currentYear = Calendar(identifier: .gregorian).dateComponents([.year], from: .now).year
                guard let month = splitLine[safe: 0] else { continue } // Feb
                guard let date = splitLine[safe: 1] else { continue } // 26
                guard let time = splitLine[safe: 2] else { continue } // 00:17:38

                var info = ""
                let dateArray = [0,1,2]
                
                for i in 0...splitLine.count - 1 {
                    if dateArray.contains(i) { continue }
                    info = info.appending(" " + splitLine[i])
                }
                
                sanatizeInfo(&info)

                let unformattedTimestamp = "\(month) \(date) \(currentYear!) \(time)" // "Aug 26 2022 00:01:40"

                
                
                
                guard let formatted = dateFormatter.date(from: unformattedTimestamp) else { continue } //Ex: 2022-08-26 07:01:40 UTC
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                let dateString = dateFormatter.string(from: formatted)
            
                let text = "\(dateString), SYSLOG, \(info)"
                self.addTextToFile(atUrl: logsFile, text: text)
                self.addTextToFile(atUrl: storylineFile, text: text)
            }
        } catch {
            self.log("Unable to parse syslog contents")
        }
    }
    
    func parseXProtectRemediatorLog() {
        
        let xprotectremLog = "\(collectionDir)/UnifiedLog/xprotect_remediator.txt"
        
        do {
            let contents = try String(contentsOf: URL(fileURLWithPath: xprotectremLog))
            let remediatorLogContents = contents.components(separatedBy: "\n")
            
            for ind in 1...remediatorLogContents.count - 1 {
                let splitLine = remediatorLogContents[ind].components(separatedBy: " ")
                
                guard let date = splitLine[safe: 0] else { continue }
                guard let time = splitLine[safe: 1] else { continue }
                let unformattedDate = date + "T" + time // ex: 2022-08-30T06:51:47.381439-0700
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
                dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                var info = ""
                
                for i in 0...splitLine.count - 1 {
                    if i == 0 || i == 1 { continue }
                    info = info.appending(" " + splitLine[i])
                }
                
                sanatizeInfo(&info)
                
                guard let dateZone = dateFormatter.date(from: unformattedDate) else { continue }
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                let formattedDate = dateFormatter.string(from: dateZone)
                let text = "\(formattedDate), XPROTECT_REMEDIATOR, \(info)"
                self.addTextToFile(atUrl: logsFile, text: text)
                self.addTextToFile(atUrl: self.storylineFile, text: text)
            }
        } catch {
            self.log("Unable to parse XPR contents")
        }
    }
    
    fileprivate func sanatizeInfo(_ info: inout String) {
        info = info.replacingOccurrences(of: ",", with: "")
        info = info.replacingOccurrences(of: "\"", with: "")
    }
    
    func run() {
        self.log("Parsing install log...")
        parseInstallLog()
        
        self.log("Parsing system log...")
        parseSysLog()
        
        self.log("Parsing XProtect Remediator log...")
        parseXProtectRemediatorLog()
    }
}
