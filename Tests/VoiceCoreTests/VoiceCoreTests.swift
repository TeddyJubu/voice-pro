import XCTest
@testable import VoiceCore

final class VoiceCoreTests: XCTestCase {
    func testMockPipelineRuns() async {
        let result = await MockPipeline().run()
        XCTAssertEqual(result, .speaking)
    }
}
