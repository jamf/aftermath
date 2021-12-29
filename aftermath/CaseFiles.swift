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
    
    static func CreateCaseDir() {
        do {
            try FileManager.default.createDirectory(at: caseDir, withIntermediateDirectories: true, attributes: nil)
            print("Aftermath directory created at \(caseDir.relativePath)")
        } catch {
            print(error)
        }
    }
}
