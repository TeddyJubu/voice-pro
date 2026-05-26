import Foundation
import VoiceCore

public struct CerebrasClient: LLMProvider {
    public init() {}
    public func streamReply(_ request: LLMRequest) async throws -> AsyncStream<LLMEvent> {
        AsyncStream { continuation in
            continuation.yield(.token("mock:" + request.userText))
            continuation.yield(.done)
            continuation.finish()
        }
    }
}
