//
//  AftermathTests.swift
//  aftermath
//
//  Copyright 2022 JAMF Software, LLC
//

import XCTest

class AftermathTests: XCTestCase {

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

    func testDateFromEpochTimestamp() {
        // Given
        let date = Date.distantFuture.timeIntervalSince1970

        // When
        let actualDate = Aftermath.dateFromEpochTimestamp(timeStamp: date)

        // Then
        XCTAssertEqual(actualDate, "4001-01-01T00:00:00")
    }

    // MARK: dateFromEpochTimestamp

    func testStandardizeMetadataTimestamp() {
        // Given
        let date = Date.distantFuture

        // When
        let actualDate = Aftermath.standardizeMetadataTimestamp(timeStamp: "\(date)")

        // Then
        XCTAssertEqual(actualDate, "4001-01-01T00:00:00")
    }

    // MARK: sortCSV

    func testSortCSVWithDateFromEpochTimestamp() throws {
        // Given
        let oldestDate = Date.distantPast
        let middleDate = Date()
        let newestDate = Date.distantFuture

        let oldestTimestamp = Aftermath.dateFromEpochTimestamp(timeStamp: oldestDate.timeIntervalSince1970)
        let middlestTimestamp = Aftermath.dateFromEpochTimestamp(timeStamp: middleDate.timeIntervalSince1970)
        let newestTimestamp = Aftermath.dateFromEpochTimestamp(timeStamp: newestDate.timeIntervalSince1970)

        let unsortedArr = [["\(middlestTimestamp)"], ["\(newestTimestamp)"], ["\(oldestTimestamp)"]]
        let expectedSortedArr = [["\(newestTimestamp)"], ["\(middlestTimestamp)"], ["\(oldestTimestamp)"]]

        // When
        let actualSortedArr = try Aftermath.sortCSV(unsortedArr: unsortedArr)

        // Then
        XCTAssertEqual(actualSortedArr, expectedSortedArr)
    }
}
