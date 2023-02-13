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
    var isPretty: Bool = false
    
    init() {
        if Command.options.contains(.analyze) {
            caseLogSelector = CaseFiles.analysisLogFile
            caseDirSelector = CaseFiles.analysisCaseDir
        } else {
            caseLogSelector = CaseFiles.logFile
            caseDirSelector = CaseFiles.caseDir
        }
        if Command.options.contains(.pretty) {
            isPretty = true
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
            print("\(getCurrentTimeStandardized()) - Error creating \(path)")
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
            self.log("\(getCurrentTimeStandardized()) -  Unable to copy text from file \(fromFile.relativePath) as the file does not exist")
            let _ = self.createNewCaseFile(dirUrl: toFile.deletingLastPathComponent(), filename: toFile.lastPathComponent)
            return
        }
        
        do {
            let contents = try String(contentsOf: fromFile, encoding: .ascii)
            self.addTextToFile(atUrl: toFile, text: "\(fromFile):\n\n\(contents)\n----------\n")
        } catch {
            self.log("\(getCurrentTimeStandardized())-  Unable to writing contents of \(fromFile) to \(toFile) due to error:\n\(error) ")
        }
    }
    
    func copyFileToCase(fileToCopy: URL, toLocation: URL?, newFileName: String? = nil, isAnalysis: Bool? = false) {
        if (!FileManager.default.fileExists(atPath: fileToCopy.relativePath)) {
            self.log("\(getCurrentTimeStandardized()) -  Unable to copy file \(fileToCopy.relativePath) as the file does not exist")
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
            self.log("\(getCurrentTimeStandardized()) - Error copying \(fileToCopy.relativePath) to \(dest)")
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
        var xattr: String = ""
        
        if fromFile.path.contains(",") {
            let sanitized = fromFile.path.replacingOccurrences(of: ",", with: " ")
            metadata = "\(sanitized),"
        } else {
            metadata = "\(fromFile.path),"
        }
        
        if let birth = helpers.getFileBirth(fromFile: fromFile) {
            birthTimestamp = Aftermath.dateFromEpochTimestamp(timeStamp: birth)
            metadata.append("\(birthTimestamp),")
        
        } else {
            metadata.append("unknwon,")
        }
        
        if let lastModified = helpers.getFileLastModified(fromFile: fromFile) {
            lastModifiedTimestamp = Aftermath.dateFromEpochTimestamp(timeStamp: lastModified)
            metadata.append("\(lastModifiedTimestamp),")
        } else {
            metadata.append("unknown,")
        }
        
        if let lastAccessed = helpers.getFileLastAccessed(fromFile: fromFile) {
            lastAccessedTimestamp = Aftermath.dateFromEpochTimestamp(timeStamp: lastAccessed)
            metadata.append("\(lastAccessedTimestamp),")
        } else {
            metadata.append("unknown,")
        }
           
        if let permissions = helpers.getFilePermissions(fromFile: fromFile) {
            metadata.append("\(String(permissions).dropFirst(3)),")
        } else {
            metadata.append("unknwon,")
        }
        
        if let uid = helpers.getFileUid(fromFile: fromFile) {
            metadata.append("\(uid),")
        } else {
            metadata.append("unknown,")
        }
        
        if let gid = helpers.getFileGid(fromFile: fromFile) {
            metadata.append("\(gid),")
        } else {
            metadata.append("unknown,")
        }
        
        do {
            let xattrs = try fromFile.listExtendedAttributes()
            if xattrs.isEmpty {
                xattr.append("none,")
            } else { xattrs.forEach { xattr.append("\($0) ") } }
            
            metadata.append("\(xattr),")
        } catch {
            xattr.append("unknown,")
            self.log("Unable to capture extended attributes for \(fromFile.path) due to error: \(error)")
        }
        
        if let mditem = MDItemCreate(nil, fromFile.path as CFString),
            let mdnames = MDItemCopyAttributeNames(mditem),
            let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any] {
            
            // this is last in case array is longer than 1 or 2 items
            if let downloadedFrom = mdattrs[kMDItemWhereFroms as String] {
                if let downloadedArr = downloadedFrom as Any as? [String] {
                    for downloaded in downloadedArr {
                        metadata.append("\(downloaded) ")
                    }
                }
            }
                
        } else {
            metadata.append("unknown,")
        }
            
        self.addTextToFile(atUrl: CaseFiles.metadataFile, text: metadata)
    }
    
    func log(_ note: String, displayOnly: Bool = false, file: String = #file) {
        
        let module = URL(fileURLWithPath: file).lastPathComponent
        let entry = "\(getCurrentTimeStandardized()) - \(module) - \(note)"
        
        if isPretty {
            let colorized = "\(Color.magenta.rawValue)\(getCurrentTimeStandardized())\(Color.colorstop.rawValue) - \(Color.yellow.rawValue)\(module)\(Color.colorstop.rawValue) - \(Color.cyan.rawValue)\(note)\(Color.colorstop.rawValue)"
            print(colorized)
        } else {
            let plainText = "\(getCurrentTimeStandardized()) - \(module) - \(note)"
            print(plainText)
        }
        
        if displayOnly == false {
            addTextToFile(atUrl: caseLogSelector, text: entry)
        }
    }
    
    func getCurrentTimeStandardized() -> String {
        let testFormatter = DateFormatter()
        testFormatter.dateStyle = .full
        testFormatter.timeStyle = .full
        testFormatter.locale = Locale(identifier: "en_US_POSIX")
        testFormatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss'Z'"
        
        let currentDateTime = Date()
        
        return testFormatter.string(from: currentDateTime)
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
