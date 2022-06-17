//
//  CaseFiles.swift
//  aftermath
//
//  Created by Jaron Bradley on 12/10/21.


import Foundation

struct CaseFiles {
    public var caseDir:URL
    public var logFile:URL
    public var analysisCaseDir: URL
    public var analysisLogFile: URL
        

    init() {
        self.caseDir = location
        self.logFile = location.appendingPathComponent("aftermath.log")
        
        self.analysisCaseDir = URL(fileURLWithPath: "/tmp/Aftermath_Analysis_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())")
        self.analysisLogFile = self.analysisCaseDir.appendingPathComponent("aftermath_analysis.log")
    }
    
    func CreateAnalysisCaseDir() {
        do {
            try FileManager.default.createDirectory(at: self.analysisCaseDir, withIntermediateDirectories: true, attributes: nil)
            print("Aftermath Analysis directory created at \(analysisCaseDir.relativePath)")
        } catch {
            print(error)
        }
    }
}


class TempDirectory {
    
    public var location: URL = URL(fileURLWithPath: "")
    
    func createTempDirectory() -> URL {
        let destinationURL = URL(fileURLWithPath: "/tmp/")

        do {
            let temporaryDirectoryURL =
                try FileManager.default.url(for: .itemReplacementDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: destinationURL,
                                            create: false)
            let temporaryFilename = "Aftermath_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())"

            let temporaryFileURL =
                temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
            
            try FileManager.default.createDirectory(at: temporaryFileURL, withIntermediateDirectories: true, attributes: nil)
            
            print("Aftermath directory created at \(temporaryFileURL.relativePath)")
            location = temporaryFileURL
            return temporaryFileURL

        } catch {
            print(error)
            exit(1)
        }
    }
    
    func moveTempDirectory(location: URL) {
        let endURL = URL(fileURLWithPath: "/tmp/\(location.lastPathComponent)")

        print("Moving Aftermath directory from \(location.relativePath) to \(endURL.relativePath)")
        do {
            try FileManager.default.copyItem(at: location, to: endURL)
        } catch {
            print(error)
            exit(1)
        }
    }
}
