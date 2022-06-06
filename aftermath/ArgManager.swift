//
//  ArgParser.swift
//  aftermath
//
//

import Foundation


class ArgManager {
    let availableArgs = ["--analyze", "--cleanup"]
    var mode = "default"
    var analysisDir = ""
    
    init(suppliedArgs: [String]) {
        setArgs(suppliedArgs)
    }
    
    func setArgs(_ args:[String]) {
        for (x,arg) in (args).enumerated() {
            if x == 0 || !arg.starts(with: "-") {
                continue
            } else if arg == "-h" || arg == "-help" {
                self.printHelp()
            } else if arg == "--cleanup" {
                self.cleanup()
                exit(1)
            } else if arg == "--analyze" {
                if args.count > x+1 {
                    analysisDir = args[x+1]
                    if isDirectoryThatExists(path: analysisDir) {
                        mode = arg
                    } else {
                        print("Please specify a valid target path")
                    }
//                    exit(1)
                }
            } else {
                print("Unidentified argument " + arg)
                exit(1)
            }
        }
    }
    
    func isDirectoryThatExists(path: String) -> Bool {
        var isDir : ObjCBool = false
        let pathExists = FileManager.default.fileExists(atPath: path, isDirectory:&isDir)
        
        if pathExists && isDir.boolValue == true {
            return true
        }
        
        return false
    }
    
    func cleanup() {
        let enumerator = FileManager.default.enumerator(atPath: "/tmp")
        while let element = enumerator?.nextObject() as? String {
            if element.hasPrefix("Aftermath_") {
                let dirToRemove = URL(fileURLWithPath: "/tmp/\(element)")
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
    
    func printHelp() {
        print("--analyze -> Analyze the results of the Aftermath results")
        print("     usage: --analyze <path_to_file>")
        print("--cleanup -> Remove Aftermath Response Folders")
        exit(1)
    }
}
