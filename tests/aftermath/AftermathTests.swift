//
//  AftermathTests.swift
//  aftermath
//
//  Created by Maggie Zirnhelt on 8/25/22.
//

import XCTest

class AftermathTests: XCTestCase {

    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    // MARK: getPlistAsDict

    func testGetPlistAsDict() throws {
        // Given
        let url = try XCTUnwrap(URL(string: UUID().uuidString))
        let plist =
        """
        gui/501/com.jamf.protect.agent = {
            active count = 0
            path = /Library/LaunchAgents/com.jamf.protect.agent.plist
            state = spawn scheduled

            program = /Applications/JamfProtect.app/Contents/Helpers/JamfProtectAgent.app/Contents/MacOS/JamfProtectAgent
            inherited environment = {
                SSH_AUTH_SOCK => /private/tmp/com.apple.launchd.oi4pZOD54K/Listeners
            }

            default environment = {
                PATH => /usr/bin:/bin:/usr/sbin:/sbin
            }

            environment = {
                XPC_SERVICE_NAME => com.jamf.protect.agent
            }

            domain = gui/501 [100007]
            asid = 100007
            minimum runtime = 60
            exit timeout = 5
            runs = 311
            last exit code = 0

            spawn type = daemon (3)
            jetsam priority = 4
            jetsam memory limit (active) = (unlimited)
            jetsam memory limit (inactive) = (unlimited)
            jetsamproperties category = daemon
            jetsam thread limit = 32
            cpumon = default
            job state = exited

            properties = keepalive | runatload
        }
        """
        let expectedData = try XCTUnwrap(plist.data(using: .utf8))
        let expectedPlist = try XCTUnwrap(PropertyListSerialization.propertyList(from: expectedData,
                                                                                 format: nil) as? [String:Any]).customMirror

        let mockFm = MockFileManager()
        Aftermath.fm = mockFm
        mockFm.stubFileExists = { path in
            XCTAssertEqual(path, url.relativePath)
            return true
        }
        mockFm.stubContentsAtPath = { path in
            XCTAssertEqual(path, url.relativePath)
            return expectedData
        }


        // When
        let actualPlist = Aftermath.getPlistAsDict(atUrl: url)

        // Then
        XCTAssertEqual(expectedPlist.description, actualPlist.description)
    }

    // MARK: dateFromEpochTimestamp

    // MARK: standardizeMetadataTimestamp

    // MARK: readCSVRows

    // MARK: sortCSV
}
