//
//  Command.swift
//  aftermath
//
//  Copyright 2022 JAMF Software, LLC
//

 import Foundation

 struct Options: OptionSet {
     let rawValue: Int

     static let deep = Options(rawValue: 1 << 0)
     static let output = Options(rawValue: 1 << 1)
     static let analyze = Options(rawValue: 1 << 2)
     static let pretty = Options(rawValue: 1 << 3)
     static let collectDirs = Options(rawValue: 1 << 4)
     static let unifiedLogs = Options(rawValue: 1 << 5)
     
 }

@main
class Command {
    static var options: Options = []
    static var analysisDir: String? = nil
    static var outputLocation: String = "/tmp"
    static var collectDirs: [String] = []
    static var unifiedLogsFile: String? = nil
    static let version: String = "1.2.0"
    
    static func main() {
        setup(with: CommandLine.arguments)
        start()
    }

    static func setup(with fullArgs: [String]) {
        
        if NSUserName() != "root" {
            print("Aftermath must be run as root")
            print("Exiting...")
            exit(1)
        }

        let args = [String](fullArgs.dropFirst())
      
         args.forEach { arg in
             switch arg {
             case "-h", "--help": Self.printHelp()
             case "--cleanup": Self.cleanup()
             case "-d", "--deep": Self.options.insert(.deep)
             case "--pretty": Self.options.insert(.pretty)
             case "-o", "--output":
                 if let index = args.firstIndex(of: arg) {
                     Self.options.insert(.output)
                     Self.outputLocation = args[index + 1]
                 }
             case "--analyze":
                 if let index = args.firstIndex(of: arg) {
                     Self.options.insert(.analyze)
                     Self.analysisDir = args[index + 1]
                 }
             case "--collect-dirs":
                 if let index = args.firstIndex(of: arg) {
                     self.options.insert(.collectDirs)
                     var i = 1
                     while (index + i) < args.count  && !args[index + i].starts(with: "-") {
                         self.collectDirs.append(contentsOf: [args[index + i]])
                         i += 1
                     }
                 }
             case "-l", "--logs":
                 if let index = args.firstIndex(of: arg) {
                     Self.options.insert(.unifiedLogs)
                     Self.unifiedLogsFile = args[index + 1]
                 }
             case "-v", "--version":
                 print(version)
                 exit(1)
             default:
                 if !arg.starts(with: "-") {
                 } else {
                     print("Unidentified argument: \(arg)")
                     exit(9)
                 }
             }
         }
     }

    static func start() {
         printBanner()
         
         if Self.options.contains(.analyze) {
             if let name = self.analysisDir?.split(separator: "_").last?.split(separator: ".").first {
                 CaseFiles.CreateAnalysisCaseDir(filename: String(describing: name))
             }


             let mainModule = AftermathModule()
             mainModule.log("Running Aftermath Version \(version)")
             mainModule.log("Aftermath Analysis Started")
             mainModule.log("Analysis started at \(mainModule.getCurrentTimeStandardized().replacingOccurrences(of: ":", with: "_"))")

             guard let dir = Self.analysisDir else {
                 mainModule.log("Analysis directory not provided")
                 return
             }
             guard FileManager.default.isFileThatExists(path: dir) else {
                 mainModule.log("Analysis directory is not a valid directory that exists")
                 return
             }
             
             let unzippedDir = mainModule.unzipArchive(location: dir)
             
             mainModule.log("Started analysis on Aftermath directory: \(unzippedDir)")
             if #available(macOS 12, *) {
                 let analysisModule = AnalysisModule(collectionDir: unzippedDir)
                 analysisModule.run()
                 
                 mainModule.log("Finished analysis module")
             } else {
                 mainModule.log("Aftermath requires macOS 12 or later in order to analyze collection data.")
                 print("Aftermath requires macOS 12 or later in order to analyze collection data.")
             }
            
             mainModule.log("Finished analysis module")

             // Move analysis directory to output direcotry
             CaseFiles.MoveTemporaryCaseDir(outputLocation: self.outputLocation, isAnalysis: true)

             // End Aftermath
             mainModule.log("Aftermath Finished")
         } else {
             CaseFiles.CreateCaseDir()
             let mainModule = AftermathModule()
             mainModule.log("Running Aftermath Version \(version)")
             mainModule.log("Aftermath Collection Started")
             mainModule.log("Collection started at \(mainModule.getCurrentTimeStandardized())")
             mainModule.addTextToFile(atUrl: CaseFiles.metadataFile, text: "file,birth,modified,accessed,permissions,uid,gid,xattr,downloadedFrom")
             

             // System Recon
             mainModule.log("Started system recon")
             let systemReconModule = SystemReconModule()
             systemReconModule.run()
             mainModule.log("Finished system recon")


             // Network
             mainModule.log("Started gathering network information...")
             let networkModule = NetworkModule()
             networkModule.run()
             mainModule.log("Finished gathering network information")


             // Processes
             mainModule.log("Starting process dump...")
             let procModule = ProcessModule()
             procModule.run()
             mainModule.log("Finished gathering process information")


             // Persistence
             mainModule.log("Starting Persistence Module")
             let persistenceModule = PersistenceModule()
             persistenceModule.run()
             mainModule.log("Finished logging persistence items")

             
             // FileSystem
             mainModule.log("Started gathering file system information...")
             let fileSysModule = FileSystemModule()
             fileSysModule.run()
             mainModule.log("Finished gathering file system information")


             // Artifacts
             mainModule.log("Started gathering artifacts...")
             let artifactModule = ArtifactsModule()
             artifactModule.run()
             mainModule.log("Finished gathering artifacts")

             // Logs
             mainModule.log("Started logging unified logs")
             let unifiedLogModule = UnifiedLogModule(logFile: unifiedLogsFile)
             unifiedLogModule.run()
             mainModule.log("Finished logging unified logs")
             
             mainModule.log("Finished running Aftermath collection")
             
             // Copy from cache to output
             CaseFiles.MoveTemporaryCaseDir(outputLocation: self.outputLocation, isAnalysis: false)

             // End Aftermath
             mainModule.log("Aftermath Finished")
         }
     }

     static func cleanup() {
         // remove any aftermath directories from tmp and /var/folders/zz
         let potentialPaths = ["/tmp", "/var/folders/zz"]
         for p in potentialPaths {
             let enumerator = FileManager.default.enumerator(atPath: p)
             while let element = enumerator?.nextObject() as? String {
                 if element.contains("Aftermath_") {
                     let dirToRemove = URL(fileURLWithPath: "\(p)/\(element)")
                     do {
                         try FileManager.default.removeItem(at: dirToRemove)
                         print("Removed \(dirToRemove.relativePath)")
                     } catch {
                         print("Error removing \(dirToRemove.relativePath)")
                         print(error)
                     }
                 }
             }
         }
         exit(1)
     }

     static func printHelp() {
         print("-o -> specify an output location for Aftermath results (defaults to /tmp)")
         print("     usage: -o Users/user/Desktop ")
         print("            -o Users/user/Desktop/outputFile.zip ")
         print("--analyze -> Analyze the results of the Aftermath results")
         print("     usage: --analyze <path_to_file>")
         print("--collect-dirs -> specify locations of (space-separated) directories to dump those raw files")
         print("    usage: --collect-dirs /Users/<USER>/Downloads /tmp")
         print("--deep -> performs deep scan and captures metadata from Users entire directory (WARNING: this may be time-consuming)")
         print("--logs -> specify an external text file with unified log predicates to parse")
         print("    usage: --logs /Users/<USER>/Desktop/myPredicates.txt")
         print("--pretty -> colorize Terminal output")
         print("--cleanup -> remove Aftermath Folders in default locations")
         exit(1)
     }
    
    static func printBanner() {
        print(#"""
              ___    ______                            __  __
             /   |  / __/ /____  _________ ___  ____ _/ /_/ /_
            / /| | / /_/ __/ _ \/ ___/ __ `__ \/ __ `/ __/ __ \
           / ___ |/ __/ /_/  __/ /  / / / / / / /_/ / /_/ / / /
          /_/  |_/_/  \__/\___/_/  /_/ /_/ /_/\__,_/\__/_/ /_/
                                                                    
        """#)
    }
 }
