import Foundation
import VoiceDaemon

let args = CommandLine.arguments
if args.dropFirst().first == "status" {
    print(VoiceDaemon().status())
} else {
    print("voice-pro: use `status`")
}
