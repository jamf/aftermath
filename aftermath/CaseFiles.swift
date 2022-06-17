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
        print("Moving temp dir from \(location))")
        do {
            try FileManager.default.copyItem(at: location, to: URL(fileURLWithPath: "/tmp/\(location.lastPathComponent)"))
        } catch {
            print(error)
            exit(1)
        }
    }
}
