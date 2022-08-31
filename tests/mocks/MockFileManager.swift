//
//  MockFileManager.swift
//  aftermath
//
//  Copyright 2022 JAMF Software, LLC
//

import Foundation

class MockFileManager: FileManager {

    var stubFileExists: ((String) -> Bool)?
    override func fileExists(atPath: String) -> Bool {
        stubFileExists!(atPath)
    }

    var stubContentsAtPath: ((String) -> Data?)?
    override func contents(atPath path: String) -> Data? {
        stubContentsAtPath!(path)
    }
}
