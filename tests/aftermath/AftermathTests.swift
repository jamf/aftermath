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
        let path = try XCTUnwrap(Bundle(for: type(of : self)).path(forResource: "dummyPlist.plist",
                                                                   ofType: nil))
        let url = try XCTUnwrap(URL(fileURLWithPath: path))
        let expectedData = try Data(contentsOf: url)
        let expectedPlist = try XCTUnwrap(PropertyListSerialization.propertyList(from: expectedData,
                                                                                 format: nil) as? [String:Any])

        let mockFm = MockFileManager()
        Aftermath.fm = mockFm
        mockFm.stubFileExists = { path in
            XCTAssertEqual(path, url.relativePath)
            return true
        }

        // When
        let actualPlist = Aftermath.getPlistAsDict(atUrl: url)

        // Then
        XCTAssertEqual(actualPlist.description, expectedPlist.description)
    }

    // MARK: dateFromEpochTimestamp

    // MARK: standardizeMetadataTimestamp

    // MARK: readCSVRows

    // MARK: sortCSV
}
