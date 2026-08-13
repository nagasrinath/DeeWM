public struct MoveNodeToMasterCmdArgs: CmdArgs {
    /*conforms*/ public var commonState: CmdArgsCommonState
    fileprivate init(rawArgs: StrArrSlice) { self.commonState = .init(rawArgs) }
    public static let parser: CmdParser<Self> = .init(
        kind: .moveNodeToMaster,
        help: move_node_to_master_help_generated,
        flags: [:],
        posArgs: [],
    )

    public init(rawArgs: [String]) {
        self.commonState = .init(rawArgs.slice)
    }
}

func parseMoveNodeToMasterCmdArgs(_ args: StrArrSlice) -> ParsedCmd<MoveNodeToMasterCmdArgs> {
    parseSpecificCmdArgs(MoveNodeToMasterCmdArgs(rawArgs: args), args)
}

let move_node_to_master_help_generated = """
USAGE
  move-node-to-master

OPTIONS
  -h, --help                      Print help

NOTES
  * Moves the focused window to the master position (index 0) of its master-stack tiling container.
  * If the focused window's container isn't a master-stack container, it's inserted at index 0 as usual.
"""
