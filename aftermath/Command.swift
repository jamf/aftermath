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
     static let esLogs = Options(rawValue: 1 << 6)
     static let disable = Options(rawValue: 1 << 7)
 }

@main
class Command {
    static var options: Options = []
    static var analysisDir: String? = nil
    static var outputLocation: String = "/tmp"
    static var collectDirs: [String] = []
    static var unifiedLogsFile: String? = nil
    static var esLogs: [String] = ["create", "exec", "mmap"]
    static let version: String = "2.2.1"
    static var disableFeatures: [String:Bool] = ["all": false, "browsers": false, "browser-killswitch": false, "databases": false, "filesystem": false, "proc-info": false, "slack": false, "ul": false]
    
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
             case "--cleanup": Self.cleanup(defaultRun: false)
             case "-d", "--deep": Self.options.insert(.deep)
             case "--pretty": Self.options.insert(.pretty)
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
             case "--disable":
                 if let index = args.firstIndex(of: arg) {
                     Self.options.insert(.disable)
                     var i = 1
                     while (index + i) < args.count && !args[index + i].starts(with: "-") {
                         for k in self.disableFeatures.keys {
                             if args[index + i] == "all" {
                                 for k in self.disableFeatures.keys {
                                     self.disableFeatures[k] = true
                                 }
                                 break
                             }

                             if args[index + i] == k {
                                 self.disableFeatures[k] = true
                                 break
                             }
                         }
                         i += 1
                     }
                 }
             case "--es-logs":
                 if let index = args.firstIndex(of: arg) {
                     Self.options.insert(.esLogs)
                     self.esLogs = []
                     var i = 1
                     while (index + i) < args.count && !args[index + i].starts(with: "-") {
                         self.esLogs.append(contentsOf: [args[index + i]])
                         i += 1
                     }
                 }
             case "-l", "--logs":
                 if let index = args.firstIndex(of: arg) {
                     Self.options.insert(.unifiedLogs)
                     Self.unifiedLogsFile = args[index + 1]
                 }
             case "-o", "--output":
                 if let index = args.firstIndex(of: arg) {
                     Self.options.insert(.output)
                     Self.outputLocation = args[index + 1]
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
        cleanup(defaultRun: true)
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
             

             // eslogger
             if #available(macOS 13, *) {
                  let esModule = ESModule()
                  esModule.run()
             } else {
                 print("Unable to run eslogger due to unavailability on this OS. Requires macOS 13 or higher.")
             }

             
             // tcpdump
             let pcapModule = NetworkModule()
             pcapModule.pcapRun()

             
             // System Recon
             let systemReconModule = SystemReconModule()
             systemReconModule.run()


             // Network
             let networkModule = NetworkModule()
             networkModule.run()


             // Processes
             let procModule = ProcessModule()
             procModule.run()


             // Persistence
             let persistenceModule = PersistenceModule()
             persistenceModule.run()

             
             // FileSystem
             let fileSysModule = FileSystemModule()
             fileSysModule.run()
             
             

             // Artifacts
             let artifactModule = ArtifactsModule()
             artifactModule.run()

             
             // Logs
             let unifiedLogModule = UnifiedLogModule(logFile: unifiedLogsFile)
             unifiedLogModule.run()
             
                          
             mainModule.log("Finished running Aftermath collection")
             
             // Copy from cache to output
             CaseFiles.MoveTemporaryCaseDir(outputLocation: self.outputLocation.expandingTildeInPath(), isAnalysis: false)

             // End Aftermath
             mainModule.log("Aftermath Finished")
         }
     }

    static func cleanup(defaultRun: Bool) {
         // remove any aftermath directories from /var/folders/zz and clean up /tmp if running this as a standalone command
        var potentialPaths = ["/var/folders/zz"]
        if !defaultRun { potentialPaths.append("/tmp") }

         for p in potentialPaths {
             let enumerator = FileManager.default.enumerator(atPath: p)
             while let element = enumerator?.nextObject() as? String {
                 if element.contains("Aftermath_") {
                     let dirToRemove = URL(fileURLWithPath: "\(p)/\(element)")
                     do {
                         try FileManager.default.removeItem(at: dirToRemove)
                         if !defaultRun {print("Removed \(dirToRemove.relativePath)") }
                     } catch {
                         print("Error removing \(dirToRemove.relativePath)")
                         print(error)
                     }
                 }
             }
         }
        if !defaultRun { exit(1) }
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
         print("--disable -> disable a set of aftermath features that may collect personal user data")
         print("    usage: --disable browsers browser-killswitch databases filesystem proc-info slack ul")
         print("           --disable all")
         print("--es-logs -> specify which Endpoint Security events (space-separated) to collect (defaults are: create exec mmap)")
         print("    usage: --es-logs exec open rename")
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
