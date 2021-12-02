//
//  FileManager.swift
//  aftermath
//
//

import Foundation

public extension FileManager {

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
    
}
