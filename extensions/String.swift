//
//  String.swift
//  aftermath
//
//  Copyright  2022 JAMF Software, LLC
//

import Foundation

public extension String {
    
    func sha256() -> String{
        if let stringData = self.data(using: String.Encoding.utf8) {
            return stringData.sha256()
        }
        return ""
    }
    
    func expandingTildeInPath() -> String {
        return self.replacingOccurrences(of: "~", with: FileManager.default.homeDirectoryForCurrentUser.path)
    }
}
