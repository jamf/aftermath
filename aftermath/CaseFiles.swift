//
//  CaseFiles.swift
//  aftermath
//
//  Created by Jaron Bradley on 12/10/21.
//

import Foundation

struct CaseFiles {
    static let caseDir = URL(fileURLWithPath: "/tmp/Aftermath_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())")
    static let logFile = caseDir.appendingPathComponent("aftermath.log")
    static let analysisCaseDir = URL(fileURLWithPath: "/tmp/Aftermath_Analysis_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())")
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
}
