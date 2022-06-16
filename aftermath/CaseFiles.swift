//
//  CaseFiles.swift
//  aftermath
//
//  Created by Jaron Bradley on 12/10/21.


//import Foundation
//
//struct CaseFiles {
////    static let caseDir = URL(fileURLWithPath: "/tmp/Aftermath_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())")
////    static let logFile = caseDir.appendingPathComponent("aftermath.log")
////
//    let caseDir: URL
//    let logFile: URL
//    static let analysisCaseDir = URL(fileURLWithPath: "/tmp/Aftermath_Analysis_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())")
//    static let analysisLogFile = analysisCaseDir.appendingPathComponent("aftermath_analysis.log")
//
//    public static var shared = CaseFiles()
//
//
//    init(tempDir: URL) {
//        self.caseDir = tempDir
//        self.logFile = tempDir.appendingPathComponent("aftermath.log")
//    }
//
//    func CreateCaseDir() {
//        do {
//            try FileManager.default.createDirectory(at: caseDir, withIntermediateDirectories: true, attributes: nil)
//            print("Aftermath directory created at \(caseDir.relativePath)")
//        } catch {
//            print(error)
//        }
//    }
//
//    // -------------------
//
//
//
//
//
//
//    // --------------------
//
//
//
//    static func CreateAnalysisCaseDir() {
//        do {
//            try FileManager.default.createDirectory(at: analysisCaseDir, withIntermediateDirectories: true, attributes: nil)
//            print("Aftermath Analysis directory created at \(analysisCaseDir.relativePath)")
//        } catch {
//            print(error)
//        }
//    }
//}

//
//import Foundation
//
//struct CaseFile {
//    let path: URL
//
//    init(path: URL) {
//        do {
//            try FileManager.default.createDirectory(at: path, withIntermediateDirectories: true, attributes: nil)
//        } catch {
//            // do something
//        }
//        self.path = path
//    }
//}
//
//struct CaseFiles {
//    static let tmpDir = URL(fileURLWithPath: "/var/log/boop_\(Date().ISO8601Format())")
////    static let logFile = caseDir.appendingPathComponent("aftermath.log")
////    static let analysisCaseDir = URL(fileURLWithPath: "/tmp/Aftermath_Analysis_\("")_\(Date().ISO8601Format())")
////    static let analysisLogFile = analysisCaseDir.appendingPathComponent("aftermath_analysis.log")
//
//    public static var shared = CaseFiles()
//
//    public let file: CaseFile
//
//    init() {
//        var caseDir: URL
//        let destinationURL = URL(fileURLWithPath: "/tmp/")
//
//        do {
//            let temporaryDirectoryURL =
//                try FileManager.default.url(for: .itemReplacementDirectory,
//                                            in: .userDomainMask,
//                                            appropriateFor: destinationURL,
//                                            create: false)
//            let temporaryFilename = "Aftermath_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())"
//
//            let temporaryFileURL =
//                temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
//            tmpDir = temporaryFileURL
//            print(temporaryFileURL)
//        } catch {
//            print(error)
//        }
//        self.file = CaseFile(path: caseDir)
//    }
//}

//class TempFiles {
//
//
//    func createTempDir() -> URL {
//            let destinationURL = URL(fileURLWithPath: "/tmp/")
//
//                do {
//                    let temporaryDirectoryURL =
//                        try FileManager.default.url(for: .itemReplacementDirectory,
//                                                    in: .userDomainMask,
//                                                    appropriateFor: destinationURL,
//                                                    create: false)
//                    let temporaryFilename = "Aftermath_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())"
//
//                    let temporaryFileURL =
//                        temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
//                    print(temporaryFileURL)
//                    return temporaryFileURL
//
//                } catch {
//                    print(error)
//                    exit(1)
//                }
//
//    }
//}


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

//    let analysisCaseDir = URL(fileURLWithPath: "/tmp/Aftermath_Analysis_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())")
//    let analysisLogFile = analysisCaseDir.appendingPathComponent("aftermath_analysis.log")
    

//    func CreateCaseDir() {
//        do {
//            try FileManager.default.createDirectory(at: caseDir, withIntermediateDirectories: true, attributes: nil)
//            print("Aftermath directory created at \(caseDir.relativePath)")
//        } catch {
//            print(error)
//        }
//    }

//    func CreateCaseDir() {
//        let destinationURL = URL(fileURLWithPath: "/tmp/")
//
//                do {
//                    let temporaryDirectoryURL =
//                        try FileManager.default.url(for: .itemReplacementDirectory,
//                                                    in: .userDomainMask,
//                                                    appropriateFor: destinationURL,
//                                                    create: true)
//                    let temporaryFilename = "Aftermath_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())"
//
//                    let temporaryFileURL =
//                        temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
//                    print(temporaryFileURL)
//                    self.caseDir = temporaryFileURL
//                    self.logFile = temporaryFileURL.appendingPathComponent("aftermath.log")
//
//                } catch {
//                    print(error)
//                    exit(1)
//                }
//    }
    // -------------------


}



    // --------------------



//    func CreateAnalysisCaseDir() {
//        do {
//            try FileManager.default.createDirectory(at: analysisCaseDir, withIntermediateDirectories: true, attributes: nil)
//            print("Aftermath Analysis directory created at \(analysisCaseDir.relativePath)")
//        } catch {
//            print(error)
//        }
//    }
//}


class TempDirectory {
    
    public var location: URL = URL(fileURLWithPath: "")
    
    func createTempDirectory() -> URL {
        let destinationURL = URL(fileURLWithPath: "/tmp/")

        do {
            let temporaryDirectoryURL =
                try FileManager.default.url(for: .itemReplacementDirectory,
                                            in: .userDomainMask,
                                            appropriateFor: destinationURL,
                                            create: true)
            let temporaryFilename = "Aftermath_\(Host.current().localizedName ?? "")_\(Date().ISO8601Format())"

            let temporaryFileURL =
                temporaryDirectoryURL.appendingPathComponent(temporaryFilename)
            print(temporaryFileURL)
            location = temporaryFileURL
            return temporaryFileURL
          

        } catch {
            print(error)
            exit(1)
        }
    }
    
      

}
