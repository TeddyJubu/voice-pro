// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "VoicePro",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "VoiceCore", targets: ["VoiceCore"]),
        .library(name: "VoiceCerebras", targets: ["VoiceCerebras"]),
        .library(name: "VoiceMCP", targets: ["VoiceMCP"]),
        .library(name: "VoiceDaemon", targets: ["VoiceDaemon"]),
        .executable(name: "voice-pro", targets: ["VoiceCLI"]),
        .executable(name: "voice-pro-mcp", targets: ["VoiceMCPExecutable"])
    ],
    targets: [
        .target(name: "VoiceCore"),
        .target(name: "VoiceCerebras", dependencies: ["VoiceCore"]),
        .target(name: "VoiceMCP", dependencies: ["VoiceCore"]),
        .target(name: "VoiceDaemon", dependencies: ["VoiceCore", "VoiceCerebras", "VoiceMCP"]),
        .executableTarget(name: "VoiceCLI", dependencies: ["VoiceCore", "VoiceDaemon"]),
        .executableTarget(name: "VoiceMCPExecutable", dependencies: ["VoiceMCP"]),
        .testTarget(name: "VoiceCoreTests", dependencies: ["VoiceCore"]),
        .testTarget(name: "VoiceCerebrasTests", dependencies: ["VoiceCerebras"]),
        .testTarget(name: "VoiceMCPTests", dependencies: ["VoiceMCP"]),
        .testTarget(name: "VoiceCLITests", dependencies: ["VoiceDaemon"]),
        .testTarget(name: "VoiceSecurityTests", dependencies: ["VoiceCore", "VoiceMCP"]),
    ]
)
