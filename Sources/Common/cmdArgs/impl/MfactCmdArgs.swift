public struct MfactCmdArgs: CmdArgs {
    /*conforms*/ public var commonState: CmdArgsCommonState
    fileprivate init(rawArgs: StrArrSlice) { self.commonState = .init(rawArgs) }
    public static let parser: CmdParser<Self> = .init(
        kind: .mfact,
        help: mfact_help_generated,
        flags: [:],
        posArgs: [
            newMandatoryPosArgParser(\.amount, parseMfactAmount, placeholder: "[+|-]<number>"),
        ],
    )

    public var amount: Lateinit<MfactCmdArgs.Amount> = .uninitialized

    public init(rawArgs: [String], amount: Amount) {
        self.commonState = .init(rawArgs.slice)
        self.amount = .initialized(amount)
    }

    public enum Amount: Equatable, Sendable {
        case set(Double)
        case add(Double)
        case subtract(Double)
    }
}

func parseMfactCmdArgs(_ args: StrArrSlice) -> ParsedCmd<MfactCmdArgs> {
    parseSpecificCmdArgs(MfactCmdArgs(rawArgs: args), args)
}

private func parseMfactAmount(_ i: PosArgParserInput) -> ParsedCliArgs<MfactCmdArgs.Amount> {
    if let number = Double(i.arg.removePrefix("+").removePrefix("-")) {
        switch true {
            case i.arg.starts(with: "+"): .succ(.add(number), advanceBy: 1)
            case i.arg.starts(with: "-"): .succ(.subtract(number), advanceBy: 1)
            default: .succ(.set(number), advanceBy: 1)
        }
    } else {
        .fail("<number> argument must be a number", advanceBy: 1)
    }
}

let mfact_help_generated = """
USAGE
  mfact [+|-]<number>

OPTIONS
  -h, --help                      Print help

ARGUMENTS
  [+|-]<number>                   Absolute (e.g. 0.6) or relative (e.g. +0.05, -0.05) value for the master area
                                   split ratio (mfact) of the focused window's master-stack container.
                                   The final value is clamped to the [0.05, 0.95] range.

NOTES
  * Only has effect when the target container's layout is 'master-stack'
"""
