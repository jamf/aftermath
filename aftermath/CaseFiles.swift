//
//  CaseFiles.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC


import Foundation
import ZIPFoundation

struct CaseFiles {
    static let caseDir = FileManager.default.temporaryDirectory.appendingPathComponent("Aftermath_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())")
    static let logFile = caseDir.appendingPathComponent("aftermath.log")
    static let analysisCaseDir = FileManager.default.temporaryDirectory.appendingPathComponent("Aftermath_Analysis_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())")
    static let analysisLogFile = analysisCaseDir.appendingPathComponent("aftermath_analysis.log")
    static let metadataFile = caseDir.appendingPathComponent("metadata.csv")
    static let fm = FileManager.default
    
    static func CreateCaseDir() {
        do {
            try fm.createDirectory(at: caseDir, withIntermediateDirectories: true, attributes: nil)
            print("Temporary Aftermath directory created at \(caseDir.relativePath)")
        } catch {
            print(error)
        }
    }
    
    static func CreateAnalysisCaseDir() {
        do {
            try fm.createDirectory(at: analysisCaseDir, withIntermediateDirectories: true, attributes: nil)
            print("Temporary Aftermath Analysis directory created at \(analysisCaseDir.relativePath)")
        } catch {
            print(error)
        }
    }
    
    static func MoveCaseDir(outputDir: String) {
        
        print("Moving the case directory from its temporary location. This may take some time. Please wait...")
        
        var endURL: URL
        
        if outputDir == "default" {
            
            endURL = URL(fileURLWithPath: "/tmp/\(caseDir.lastPathComponent)")
        } else {
            endURL = URL(fileURLWithPath: "\(outputDir)/\(caseDir.lastPathComponent)")
            
        }
        
        let zippedURL = endURL.appendingPathExtension("zip")

        do {
            try fm.zipItem(at: caseDir, to: endURL, shouldKeepParent: true, compressionMethod: .deflate)
            try fm.moveItem(at: endURL, to: zippedURL)
            print("Aftermath archive moved to \(zippedURL.path)")
        } catch {
            print("Unable to create archive. Error: \(error)")
        }
    }
    
    static func MoveAnalysisCaseDir() {
        let endURL = URL(fileURLWithPath: "/tmp/\(analysisCaseDir.lastPathComponent)")
        let zippedURL = endURL.appendingPathExtension("zip")
                
        do {
            try fm.zipItem(at: analysisCaseDir, to: endURL, shouldKeepParent: true, compressionMethod: .deflate)
            try fm.moveItem(at: endURL, to: zippedURL)
            print("Aftermath analysis archive moved to \(zippedURL.path)")
        } catch {
            print(error)
        }
    }
}
