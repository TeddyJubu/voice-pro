import XCTest
@testable import VoiceMCP

final class VoiceMCPTests: XCTestCase {
    func testInitialize() {
        XCTAssertEqual(MCPServer().initialize(), "ok")
    }
}
