import XCTest
@testable import aftermath

final class SantaTests: XCTestCase {
    func testCollectorAPIsDoNotCrash() {
        // These calls are safe if `santactl` is missing — they should return nil/empty rather than crash.
        _ = SantaCollector.version()
        _ = SantaCollector.status()
        _ = SantaCollector.listLogFiles()
    }
}
