import Foundation


class ArgManager {
    let availableArgs = ["--analyze", "--cleanup", "--deep", "-d", "-o", "--output", "-h", "-help"]
    var mode = "default"
    var analysisDir = "default"
    var outputDir = "default"
    var deep = false
    
    init(suppliedArgs: [String]) {
        setArgs(suppliedArgs)
    }
    
    
    
    func setArgs(_ args:[String]) {
        for (x,arg) in (args).enumerated() {
            if x == 0 || !arg.starts(with: "-") {
                continue
            }
            if arg == "-h" || arg == "-help" {
                self.printHelp()
            }
            if arg == "--cleanup" {
                self.cleanup()
                exit(1)
            }
            if arg == "--analyze" {
                if args.count > x+1 {
                    analysisDir = args[x+1]
                    if FileManager.default.fileExists(atPath: analysisDir) {
                        mode = arg
                    } else {
                        print("Please specify a valid target path")
                        exit(1)
                    }
                }
            }
            if arg == "--deep" {
                deep = true
            }
            if arg == "-o" || arg == "--output" {
                if args.count > x+1 {
                    if isDirectoryThatExists(path: args[x+1]) {
                        outputDir = args[x+1]
                    }
                } else {
                    print("Please specify a valid output directory")
                    exit(1)
                }
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
        print("-o -> specify an output location for Aftermath results")
        print("     usage: -o Users/user/Desktop")
        print("--analyze -> Analyze the results of the Aftermath results")
        print("     usage: --analyze <path_to_file>")
        print("--cleanup -> Remove Aftermath Response Folders")
        exit(1)
    }
}
