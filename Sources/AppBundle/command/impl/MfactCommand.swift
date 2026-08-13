import AppKit
import Common

struct MfactCommand: Command {
    let args: MfactCmdArgs
    /*conforms*/ let shouldResetClosedWindowsCache = false

    func run(_ env: CmdEnv, _ io: CmdIo) async -> BinaryExitCode {
        guard let target = args.resolveTargetOrReportError(env, io) else { return .fail }
        guard let window = target.windowOrNil else {
            return .fail(io.err(noWindowIsFocused))
        }
        guard let container = window.parent as? TilingContainer, container.layout == .masterStack else {
            return .fail(io.err("mfact only has effect when the focused window belongs to a 'master-stack' container"))
        }

        switch args.amount.val {
            case .set(let value): container.mfact = CGFloat(value)
            case .add(let value): container.mfact += CGFloat(value)
            case .subtract(let value): container.mfact -= CGFloat(value)
        }
        // NOTE: TilingContainer.mfact clamps itself to [0.05, 0.95] in its didSet

        return .succ
    }
}
