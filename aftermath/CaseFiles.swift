//
//  CaseFiles.swift
//  aftermath
//
//  Created by Jaron Bradley on 12/10/21.



import Foundation

struct CaseFiles {
    static let caseDir = FileManager.default.temporaryDirectory.appendingPathComponent("Aftermath_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())")
    static let logFile = caseDir.appendingPathComponent("aftermath.log")
    static let analysisCaseDir = FileManager.default.temporaryDirectory.appendingPathComponent("Aftermath_Analysis_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())")
    static let analysisLogFile = analysisCaseDir.appendingPathComponent("aftermath_analysis.log")
    
    static func CreateCaseDir() {
        do {
            try FileManager.default.createDirectory(at: caseDir, withIntermediateDirectories: true, attributes: nil)
            print("Aftermath directory created at \(caseDir.relativePath)")
        } catch {
            print(error)
        }
    }
    
    static func CreateAnalysisCaseDir() {
        do {
            try FileManager.default.createDirectory(at: analysisCaseDir, withIntermediateDirectories: true, attributes: nil)
            print("Aftermath Analysis directory created at \(analysisCaseDir.relativePath)")
        } catch {
            print(error)
        }
    }
    
    static func MoveCaseDir() {
        let endURL = URL(fileURLWithPath: "/tmp/\(caseDir.lastPathComponent)")
        
        do {
            try FileManager.default.copyItem(at: caseDir, to: endURL)
        } catch {
            print(error)
        }
    }
    
    static func MoveAnalysisCaseDir() {
        let endURL = URL(fileURLWithPath: "/tmp/\(analysisCaseDir.lastPathComponent)")
        
        do {
            try FileManager.default.copyItem(at: analysisCaseDir, to: endURL)
        } catch {
            print(error)
        }
    }
}
