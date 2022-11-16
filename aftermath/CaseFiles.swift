//
//  CaseFiles.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC


import Foundation
import ZIPFoundation

struct CaseFiles {
    static let caseDir = FileManager.default.temporaryDirectory.appendingPathComponent("Aftermath_\(serialNumber ?? Host.current().localizedName?.replacingOccurrences(of: " ", with: "_") ?? "")")
    static let logFile = caseDir.appendingPathComponent("aftermath.log")
    static var analysisCaseDir = FileManager.default.temporaryDirectory
    static let analysisLogFile = analysisCaseDir.appendingPathComponent("aftermath_analysis.log")
    static let metadataFile = caseDir.appendingPathComponent("metadata.csv")
    static let fm = FileManager.default
    static var serialNumber: String? {
        var platformExpert: io_service_t = 0
        if #available(macOS 12.0, *) {
            platformExpert = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("IOPlatformExpertDevice"))
        } else {
            return nil
        }

        guard platformExpert > 0 else {
            return nil
        }
        guard let serialNumber = (IORegistryEntryCreateCFProperty(platformExpert, kIOPlatformSerialNumberKey as CFString, kCFAllocatorDefault, 0).takeUnretainedValue() as? String)?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else {
            return nil
        }

        IOObjectRelease(platformExpert)
       
        return serialNumber
    }
    
    static func CreateCaseDir() {
        do {
            try fm.createDirectory(at: caseDir, withIntermediateDirectories: true, attributes: nil)
            print("Temporary Aftermath directory created at \(caseDir.relativePath)")
        } catch {
            print(error)
        }
    }
    
    static func CreateAnalysisCaseDir(filename: String) {
        self.analysisCaseDir = self.analysisCaseDir.appendingPathComponent("Aftermath_Analysis_\(filename)")
        do {
            try fm.createDirectory(at: analysisCaseDir, withIntermediateDirectories: true, attributes: nil)
            print("Temporary Aftermath Analysis directory created at \(analysisCaseDir.relativePath)")
        } catch {
            print(error)
        }
    }
    
    static func MoveTemporaryCaseDir(outputDir: String, isAnalysis: Bool) {
        print("Moving the aftermath directory from its temporary location. This may take some time. Please wait...")
    
        var localCaseDir: URL
        
        if isAnalysis {
            localCaseDir = analysisCaseDir
        } else {
            localCaseDir = caseDir
        }
        do {
            let endURL = URL(fileURLWithPath: "\(outputDir)/\(localCaseDir.lastPathComponent)")
            let zippedURL = endURL.appendingPathExtension("zip")
            
            try fm.zipItem(at: localCaseDir, to: endURL, shouldKeepParent: true, compressionMethod: .deflate)
            try fm.moveItem(at: endURL, to: zippedURL)
            print("Aftermath archive moved to \(zippedURL.path)")
    
        } catch {
            print("Unable to create archive. Error: \(error)")
        }
    }
}
