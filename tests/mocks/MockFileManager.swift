//
//  MockFileManager.swift
//  aftermath
//
//  Created by Maggie Zirnhelt on 8/25/22.
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
