import XCTest
@testable import VoiceDaemon

final class VoiceCLITests: XCTestCase {
    func testDaemonStatus() {
        XCTAssertEqual(VoiceDaemon().status(), "ready")
    }
}
