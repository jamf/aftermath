//
//  FileManager.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

public extension FileManager {

    func isDirectoryThatExists(path: String) -> Bool {
        var isDir : ObjCBool = false
        let pathExists = self.fileExists(atPath: path, isDirectory:&isDir)
        return pathExists && isDir.boolValue
    }

    func isFileThatExists(path: String) -> Bool {
       self.fileExists(atPath: path)
   }

    func deletingPathExtension(path: String) -> String {
        return URL(fileURLWithPath: path).deletingPathExtension().relativePath
    }

    @discardableResult
    class func delete(path: String) -> Error? {
        if (FileManager.default.fileExists(atPath: path)) {
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch let error {
                return error
            }
            return nil
        }
        return NSError(domain: "File does not exist", code: -1, userInfo: nil) as Error
    }
    
    func filesInDirRecursive(path: String) -> [URL] {
        let url = URL(fileURLWithPath: path)
        var files = [URL]()

        if let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey]) {
            for case let fileURL as URL in enumerator {
                do { let fileAttr = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
                    if fileAttr.isRegularFile! {
                        files.append(fileURL)
                    }
                } catch {
                    print("Error: \(error) at URL: \(fileURL)")
                }
            }
        }
        
        return files
    }
    
    func filesInDir(path: String) -> [URL] {
        let directoryURL: URL = URL(fileURLWithPath: path)
        let contents =
            try! FileManager.default.contentsOfDirectory(at: directoryURL,
                                                        includingPropertiesForKeys: nil,
                                                        options: [.skipsHiddenFiles])
        
        var urls = [URL]()
        for file in contents { urls.append(file) }
        
        return urls
    }
    
}
