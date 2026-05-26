import XCTest
import VoiceCore
@testable import VoiceCerebras

final class VoiceCerebrasTests: XCTestCase {
    func testClientStreamsMockReply() async throws {
        let client = CerebrasClient()
        let stream = try await client.streamReply(.init(systemPrompt: "s", userText: "hello"))
        var tokens: [String] = []
        for await event in stream {
            if case let .token(t) = event { tokens.append(t) }
        }
        XCTAssertEqual(tokens.first, "mock:hello")
    }
}
