import AppKit
import Common
import Foundation

struct BalanceSizesCommand: Command {
    let args: BalanceSizesCmdArgs
    /*conforms*/ let shouldResetClosedWindowsCache = false

    func run(_ env: CmdEnv, _ io: CmdIo) -> BinaryExitCode {
        guard let target = args.resolveTargetOrReportError(env, io) else { return .fail }
        balance(target.workspace.rootTilingContainer)
        return .succ
    }
}

@MainActor
private func balance(_ parent: TilingContainer) {
    if parent.layout == .masterStack {
        // master-stack doesn't use weights (see below); reset mfact to the configured default instead
        parent.mfact = CGFloat(config.defaultMfact)
    }
    for child in parent.children {
        switch parent.layout {
            case .tiles: child.setWeight(parent.orientation, 1)
            case .accordion, .masterStack: break // Do nothing
        }
        if let child = child as? TilingContainer {
            balance(child)
        }
    }
}
