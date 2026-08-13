import AppKit
import Common

struct MoveNodeToMasterCommand: Command {
    let args: MoveNodeToMasterCmdArgs
    /*conforms*/ let shouldResetClosedWindowsCache = true

    func run(_ env: CmdEnv, _ io: CmdIo) async -> BinaryExitCode {
        guard let target = args.resolveTargetOrReportError(env, io) else { return .fail }
        guard let window = target.windowOrNil else {
            return .fail(io.err(noWindowIsFocused))
        }
        guard let container = window.parent as? TilingContainer else {
            return .fail(io.err("move-node-to-master doesn't support floating windows"))
        }
        if container.children.first === window {
            return .succ // Already master. Noop
        }
        window.bind(to: container, adaptiveWeight: window.getWeight(container.orientation), index: 0)
        return .succ
    }
}
