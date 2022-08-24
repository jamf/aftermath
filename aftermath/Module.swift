//
//  Module.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC

import Foundation
import Accelerate

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
    var activeUser = NSUserName()
    let filemanager = FileManager.default
    var caseLogSelector: URL
    var caseDirSelector: URL
    
    init() {
        if Command.options.contains(.analyze) {
            caseLogSelector = CaseFiles.analysisLogFile
            caseDirSelector = CaseFiles.analysisCaseDir
        } else {
            caseLogSelector = CaseFiles.logFile
            caseDirSelector = CaseFiles.caseDir
        }
        users = getUsersOnSystem()
    }
    
    func getUsersOnSystem() -> [User] {
        var users = [User]()
        
        // Check Permissions
        if (activeUser != "root") {
            self.log("Aftermath being run in non-root mode...")
            if let homedir = NSHomeDirectoryForUser(activeUser) {
                let user = User(username:activeUser, homedir: homedir)
                users.append(user)
            }
        } else {
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
    
    func getBasicUsersOnSystem() -> [User] {
        var basicUsers = [User]()
        if let users = self.users {
            for user in users {
                if SystemUsers.allCases.contains(where: {$0.rawValue == user.username}) { continue }
                basicUsers.append(user)
            }
        }
        return basicUsers
    }
    
    func createNewDirInRoot(dirName: String) -> URL {
        let newUrl = caseDirSelector.appendingPathComponent(dirName)
        
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
    
    func copyFileToCase(fileToCopy: URL, toLocation: URL?, newFileName: String? = nil, isAnalysis: Bool? = false) {
        if (!FileManager.default.fileExists(atPath: fileToCopy.relativePath)) {
            self.log("\(Date().ISO8601Format()) -  Unable to copy file \(fileToCopy.relativePath) as the file does not exist")
            return
        }
        
        if !(isAnalysis ?? false) {
            // before copying file, capture it's metadata
            self.getFileMetadata(fromFile: fileToCopy)
        }
        
        var to = caseDirSelector
        if let toLocation = toLocation { to = toLocation }
        
        var filename = fileToCopy.lastPathComponent
        if let newFileName = newFileName {
            filename = newFileName
        }
        
        let dest = to.appendingPathComponent(filename)
        
        if filemanager.fileExists(atPath: dest.path) { return }
        
        do {
            try FileManager.default.copyItem(at:fileToCopy, to:dest)
        } catch {
            self.log("\(Date().ISO8601Format()) - Error copying \(fileToCopy.relativePath) to \(dest)")
        }
        
    }
    
    func getFileMetadata(fromFile: URL) {
                
        // ignore /private/var/audit/ directory
        if fromFile.pathComponents.contains("audit") {
            return
        }
        
        let helpers = CHelpers()
        var metadata: String
        var birthTimestamp: String
        var lastModifiedTimestamp: String
        var lastAccessedTimestamp: String
        
        
        if let mditem = MDItemCreate(nil, fromFile.path as CFString),
            let mdnames = MDItemCopyAttributeNames(mditem),
            let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any] {
            
            if fromFile.path.contains(",") {
                let sanitized = fromFile.path.replacingOccurrences(of: ",", with: " ")
                metadata = "\(sanitized),"
            } else {
                metadata = "\(fromFile.path),"
            }
            
            if let birth = mdattrs[kMDItemContentCreationDate as String] {
                birthTimestamp = Aftermath.standardizeMetadataTimestamp(timeStamp: String(describing: birth))
                metadata.append("\(birthTimestamp),")
            } else if let birthFS = mdattrs[kMDItemFSCreationDate as String] {
                birthTimestamp = Aftermath.standardizeMetadataTimestamp(timeStamp: String(describing: birthFS))
                metadata.append("\(birthTimestamp),")
            } else {
                metadata.append("unknown,")
            }
            
            if let lastModified = mdattrs[kMDItemContentModificationDate as String] {
                lastModifiedTimestamp = Aftermath.standardizeMetadataTimestamp(timeStamp: String(describing: lastModified))
                metadata.append("\(lastModifiedTimestamp),")
            } else if let lastModifiedFS = mdattrs[kMDItemFSContentChangeDate as String] {
                lastModifiedTimestamp = Aftermath.standardizeMetadataTimestamp(timeStamp: String(describing: lastModifiedFS))
                metadata.append("\(lastModifiedTimestamp),")
            } else {
                metadata.append("unknown,")
            }
            
            if let lastAccessed = mdattrs[kMDItemLastUsedDate as String] {
                lastAccessedTimestamp = Aftermath.standardizeMetadataTimestamp(timeStamp: String(describing: lastAccessed))
                metadata.append("\(lastAccessedTimestamp),")
            } else {
                metadata.append("unknown,")
            }
            
           
            if let permissions = helpers.getFilePermissions(fromFile: fromFile) {
                metadata.append("\(String(permissions).dropFirst(3)),")
            } else {
                metadata.append("unknwon,")
            }
            
            if let uid = mdattrs[kMDItemFSOwnerUserID as String] {
                metadata.append("\(uid),")
            } else {
                metadata.append("unknwon,")
            }
        
            if let gid = mdattrs[kMDItemFSOwnerGroupID as String] {
                metadata.append("\(gid),")
            } else {
                metadata.append("unknown,")
            }
            
            // this is last in case array is longer than 1 or 2 items
            if let downloadedFrom = mdattrs[kMDItemWhereFroms as String] {
                if let downloadedArr = downloadedFrom as Any as? [String] {
                    for downloaded in downloadedArr {
                        metadata.append("\(downloaded),")
                    }
                }
            } else {
                metadata.append("unknown,")
            }
            
            
            self.addTextToFile(atUrl: CaseFiles.metadataFile, text: metadata)

         } else {
             print("Can't get attributes for \(fromFile.path)")
         }
    }
    
    func log(_ note: String, displayOnly: Bool = false, file: String = #file) {
        
        let module = URL(fileURLWithPath: file).lastPathComponent
        let entry = "\(Date().ISO8601Format()) - \(module) - \(note)"
        
        let colorized = "\(Color.magenta.rawValue)\(Date().ISO8601Format())\(Color.colorstop.rawValue) - \(Color.yellow.rawValue)\(module)\(Color.colorstop.rawValue) - \(Color.cyan.rawValue)\(note)\(Color.colorstop.rawValue)"
        print(colorized)

        if displayOnly == false {
            addTextToFile(atUrl: caseLogSelector, text: entry)
        }
    }
    
    func unzipArchive(location: String) -> String {
            
        let zippedURL = URL(fileURLWithPath: location)
        let unzipped = zippedURL.deletingPathExtension()

        do {
            try filemanager.unzipItem(at: zippedURL, to: unzipped.deletingLastPathComponent())
    
        } catch {
            print(error)
        }
            
        return unzipped.path
        
    }
    
    enum Color: String {
        case black = "\u{001B}[0;30m"
        case red = "\u{001B}[0;31m"
        case green = "\u{001B}[0;32m"
        case yellow = "\u{001B}[0;33m"
        case blue = "\u{001B}[0;34m"
        case magenta = "\u{001B}[0;35m"
        case cyan = "\u{001B}[0;36m"
        case white = "\u{001B}[0;37m"
        case colorstop = "\u{001B}[0;0m"
    }
    
    enum SystemUsers: String, CaseIterable {
        case nobody = "nobody"
        case daemon = "daemon"
    }
}
