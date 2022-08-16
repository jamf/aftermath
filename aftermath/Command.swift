//
 //  Command.swift
 //  aftermath
 //
 //

 import Foundation

 struct Options: OptionSet {
     let rawValue: Int

     static let deep = Options(rawValue: 1 << 0)
     static let output = Options(rawValue: 1 << 1)
     static let analyze = Options(rawValue: 1 << 2)
 }

@main
class Command {
     static var options: Options = []
     static var analysisDir: String? = nil
     static var outputDir: String? = nil

     static func setup(with args: [String]) {

         args.forEach { arg in
             switch arg {
             case "-h", "--help": Self.printHelp()
             case "--cleanup": Self.cleanup()
             case "-d", "--deep": Self.options.insert(.deep)
             case "-o", "--output":
                 if let index = args.firstIndex(of: arg) {
                     Self.options.insert(.output)
                     Self.outputDir = args[index]
                 }
             case "--analyze":
                 if let index = args.firstIndex(of: arg) {
                     Self.options.insert(.analyze)
                     Self.analysisDir = args[index]
                 }
             default: print("Unidentified argument: \(arg)")
             }
         }
     }

     static func main() {
         if Self.options.contains(.analyze) {
             CaseFiles.CreateAnalysisCaseDir()

             let mainModule = AftermathModule()
             mainModule.log("Aftermath Analysis Started")

             guard let dir = Self.analysisDir else {
                 mainModule.log("Analysis directory not provided")
                 return
             }
             guard isDirectoryThatExists(path: dir) else {
                 mainModule.log("Analysis directory is not a valid directory that exists")
                 return
             }
             
             let unzippedDir = mainModule.unzipArchive(location: dir)
             
             mainModule.log("Started analysis on Aftermath directory: \(unzippedDir)")
             let analysisModule = AnalysisModule(collectionDir: unzippedDir)
             analysisModule.run()
             mainModule.log("Finished analysis module")

             // Move analysis directory to tmp
             CaseFiles.MoveAnalysisCaseDir()

             // End Aftermath
             mainModule.log("Aftermath Finished")
         } else {
             CaseFiles.CreateCaseDir()
             let mainModule = AftermathModule()
             mainModule.log("Aftermath Started from command")
             mainModule.addTextToFile(atUrl: CaseFiles.metadataFile, text: "file,birth,modified,accessed")

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
             let unifiedLogModule = UnifiedLogModule()
             unifiedLogModule.run()
             mainModule.log("Finished logging unified logs")


             // Copy from cache to /tmp
             guard let dir = Self.outputDir else {
                 mainModule.log("Output directory not provided")
                 return
             }
             guard isDirectoryThatExists(path: dir) else {
                 mainModule.log("Output directory is not a valid directory that exists")
                 return
             }
             CaseFiles.MoveCaseDir(outputDir: dir)

             // End Aftermath
             mainModule.log("Aftermath Finished")
         }
     }

     static func cleanup() {
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
                         print("\(Date().ISO8601Format()) - Error removing \(dirToRemove.relativePath)")
                         print(error)
                     }
                 }
             }
         }
     }

     static func isDirectoryThatExists(path: String) -> Bool {
         var isDir : ObjCBool = false
         let pathExists = FileManager.default.fileExists(atPath: path, isDirectory:&isDir)
         return pathExists && isDir.boolValue
     }

     static func printHelp() {
         print("-o -> specify an output location for Aftermath results")
         print("     usage: -o Users/user/Desktop")
         print("--analyze -> Analyze the results of the Aftermath results")
         print("     usage: --analyze <path_to_file>")
         print("--cleanup -> Remove Aftermath Response Folders")
         exit(1)
     }
 }
