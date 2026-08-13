@testable import AppBundle
import Common
import XCTest

@MainActor
final class FocusCommandMasterStackTest: XCTestCase {
    override func setUp() async throws { setUpWorkspacesForTests() }

    func testDfsNextPrevInMasterStack() async {
        Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true) // Master
            TestWindow.new(id: 2, parent: $0) // Stack 1
            TestWindow.new(id: 3, parent: $0) // Stack 2
        }

        assertEquals(focus.windowOrNil?.windowId, 1)

        await parseCommand("focus dfs-next").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(focus.windowOrNil?.windowId, 2)
        await parseCommand("focus dfs-next").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(focus.windowOrNil?.windowId, 3)

        await parseCommand("focus dfs-prev").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(focus.windowOrNil?.windowId, 2)
        await parseCommand("focus dfs-prev").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(focus.windowOrNil?.windowId, 1)
    }

    func testDfsNextPrevWrappingInMasterStack() async {
        Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            TestWindow.new(id: 1, parent: $0) // Master
            TestWindow.new(id: 2, parent: $0) // Stack 1
            TestWindow.new(id: 3, parent: $0) // Stack 2
        }

        assertEquals(Window.get(byId: 3)?.focusWindow(), true)

        await parseCommand("focus --boundaries-action wrap-around-the-workspace dfs-next").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(focus.windowOrNil?.windowId, 1)

        await parseCommand("focus --boundaries-action wrap-around-the-workspace dfs-prev").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(focus.windowOrNil?.windowId, 3)
    }

    func testDirectionalFocusInMasterStack() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true) // Master
            TestWindow.new(id: 2, parent: $0) // Stack 1
        }
        assertEquals(root.orientation, .h)
        assertEquals(focus.windowOrNil?.windowId, 1)

        await parseCommand("focus right").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(focus.windowOrNil?.windowId, 2)

        await parseCommand("focus left").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(focus.windowOrNil?.windowId, 1)
    }

    func testMoveNodeToMasterThenFocusFollowsStructure() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            TestWindow.new(id: 1, parent: $0) // Master
            TestWindow.new(id: 2, parent: $0) // Stack
        }

        assertEquals(Window.get(byId: 2)?.focusWindow(), true)
        await parseCommand("move-node-to-master").cmdOrDie.run(.defaultEnv, .emptyStdin)
        // Focus should stay on window 2, which is now the master (index 0)
        assertEquals(focus.windowOrNil?.windowId, 2)
        assertEquals(root.layoutDescription, .h_master_stack([.window(2), .window(1)]))

        await parseCommand("focus dfs-next").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(focus.windowOrNil?.windowId, 1)
    }
}
