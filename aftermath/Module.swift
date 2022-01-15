//
//  Module.swift
//  aftermath
//
//  Created by Jaron Bradley on 12/8/21.
//

import Foundation

struct User {
    let username: String
    let homedir: String
}

protocol AMProto {
    var name: String { get }
    var dirName: String { get }
    var description: String { get }
    var moduleDirRoot: URL { get }
}

class AftermathModule {
    var users: [User]?
    
    init() {
        users = getUsersOnSystem()
    }
    
    func getUsersOnSystem() -> [User] {
        var users = [User]()
        
        // Check Permissions
        let activeUser = NSUserName()
        if (activeUser != "root") {
            self.log("Aftermath being run in non-root mode...")
            if let homedir = NSHomeDirectoryForUser(activeUser) {
                let user = User(username:activeUser, homedir: homedir)
                users.append(user)
            }
        } else {
            let filemanager = FileManager.default
            let userPlists = filemanager.filesInDir(path: "/var/db/dslocal/nodes/Default/users/")
            for file in userPlists {
                let filename = file.lastPathComponent
                if !filename.hasPrefix("_") {
                    let username = file.deletingPathExtension().lastPathComponent
                    if let homedir = NSHomeDirectoryForUser(username) {
                        let user = User(username:username, homedir: homedir)
                        users.append(user)
                    }
                }
            }
        }
        
        return users
    }
    
    func createNewDirInRoot(dirName: String) -> URL {
        let newUrl = CaseFiles.caseDir.appendingPathComponent(dirName)
        
        do {
            try FileManager.default.createDirectory(at: newUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
        
        return newUrl
    }
    
    func createNewDir(dir: URL, dirname: String ) -> URL {
        let newUrl = dir.appendingPathComponent(dirname)
        
        do {
            try FileManager.default.createDirectory(at: newUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error)
        }
        
        return newUrl
    }
    
    func createNewCaseFile(dirUrl: URL, filename: String) -> URL {
        let newFile = dirUrl.appendingPathComponent(filename)
        let path = newFile.relativePath
        if !(FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)) {
            print("\(Date().ISO8601Format()) - Error creating \(path)")
        }
        
        return newFile
    }
    
    func addTextToFile(atUrl: URL, text: String) {
        if (!FileManager.default.fileExists(atPath: atUrl.relativePath)) {
            let _ = self.createNewCaseFile(dirUrl: atUrl.deletingLastPathComponent(), filename: atUrl.lastPathComponent)
        }
        
        let textWithNewLine = "\(text)\n"
        do {
            let fileHandle = try FileHandle(forWritingTo: atUrl)
                fileHandle.seekToEndOfFile()
                fileHandle.write(textWithNewLine.data(using: .utf8)!)
                fileHandle.closeFile()
        } catch {
            print("Error writing to file \(error)")
        }
    }
    
    func addTextToFileFromUrl(fromFile: URL, toFile: URL) {
        if (!FileManager.default.fileExists(atPath: fromFile.relativePath)) {
            self.log("\(Date().ISO8601Format())-  Unable to copy text from file \(fromFile.relativePath) as the file does not exist")
            let _ = self.createNewCaseFile(dirUrl: toFile.deletingLastPathComponent(), filename: toFile.lastPathComponent)
            return
        }
        
        do {
            let contents = try String(contentsOf: fromFile, encoding: .ascii)
            self.addTextToFile(atUrl: toFile, text: "\(fromFile):\n\n\(contents)\n----------\n")
        } catch {
            self.log("\(Date().ISO8601Format())-  Unable to writing contents of \(fromFile) to \(toFile) due to error:\n\(error) ")
        }
    }
    
    func copyFileToCase(fileToCopy: URL, toLocation: URL?) {
        if (!FileManager.default.fileExists(atPath: fileToCopy.relativePath)) {
            self.log("\(Date().ISO8601Format())-  Unable to copy file \(fileToCopy.relativePath) as the file does not exist")
            return
        }
        
        var to = CaseFiles.caseDir
        if let toLocation = toLocation { to = toLocation }
        
        let filename = fileToCopy.lastPathComponent
        let dest = to.appendingPathComponent(filename)
        
        do {
            try FileManager.default.copyItem(at:fileToCopy, to:dest)
        } catch {
            print("\(Date().ISO8601Format()) - Error copying \(fileToCopy.relativePath) to case directory")
        }
        
    }
    
    func log(_ note: String, displayOnly: Bool = false, file: String = #file) {
        let module = URL(fileURLWithPath: file).lastPathComponent
        let entry = "\(Date().ISO8601Format()) - \(module) - \(note)"
        print(entry)
        if displayOnly == false {
            addTextToFile(atUrl: CaseFiles.logFile, text: entry)
        }
    }
}
