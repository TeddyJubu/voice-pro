import Foundation

public struct AudioFrame: Sendable, Equatable {
    public let samples: [Float]
    public let sampleRate: Int
    public init(samples: [Float], sampleRate: Int) {
        self.samples = samples
        self.sampleRate = sampleRate
    }
}

public struct AudioChunk: Sendable, Equatable {
    public let bytes: Data
    public init(bytes: Data) { self.bytes = bytes }
}

public enum VADEvent: Sendable, Equatable { case silence, speechStart, speechEnd }
public enum ASREvent: Sendable, Equatable { case partial(String), final(String) }
public enum LLMEvent: Sendable, Equatable { case token(String), done }
public enum PipelineState: Sendable, Equatable { case idle, listening, transcribing, thinking, speaking, error(String) }

public struct LLMRequest: Sendable, Equatable {
    public let systemPrompt: String
    public let userText: String
    public init(systemPrompt: String, userText: String) {
        self.systemPrompt = systemPrompt
        self.userText = userText
    }
}

public protocol VADProvider: Sendable { func process(_ frame: AudioFrame) async throws -> VADEvent }
public protocol ASRProvider: Sendable { func transcribe(_ stream: AsyncStream<AudioFrame>) async throws -> AsyncStream<ASREvent> }
public protocol LLMProvider: Sendable { func streamReply(_ request: LLMRequest) async throws -> AsyncStream<LLMEvent> }
public protocol TTSProvider: Sendable { func synthesize(_ text: AsyncStream<String>) async throws -> AsyncStream<AudioChunk> }

public struct ToolDefinition: Sendable, Equatable { public let name: String; public init(name: String){ self.name = name } }
public struct ToolResult: Sendable, Equatable { public let output: String; public init(output: String){ self.output = output } }
public protocol ToolBridge: Sendable {
    func listTools() async throws -> [ToolDefinition]
    func callTool(name: String, arguments: [String: String]) async throws -> ToolResult
}

public actor MockPipeline {
    public init() {}
    public func run() async -> PipelineState { .speaking }
}
