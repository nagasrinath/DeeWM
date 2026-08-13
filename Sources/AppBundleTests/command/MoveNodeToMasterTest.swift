@testable import AppBundle
import Common
import XCTest

@MainActor
final class MoveNodeToMasterTest: XCTestCase {
    override func setUp() async throws { setUpWorkspacesForTests() }

    func testParse() {
        assertNil(parseCommand("move-node-to-master").errorOrNil)
    }

    func testMoveStackWindowToMaster() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            TestWindow.new(id: 1, parent: $0) // Master (index 0)
            TestWindow.new(id: 2, parent: $0) // Stack (index 1)
        }

        assertEquals(Window.get(byId: 2)?.focusWindow(), true)

        let result = await parseCommand("move-node-to-master").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(result.exitCode.rawValue, 0)
        assertEquals(root.layoutDescription, .h_master_stack([.window(2), .window(1)]))
    }

    func testMoveAlreadyMaster_isNoop() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            TestWindow.new(id: 1, parent: $0) // Master
            TestWindow.new(id: 2, parent: $0) // Stack
        }

        assertEquals(Window.get(byId: 1)?.focusWindow(), true)

        let result = await parseCommand("move-node-to-master").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(result.exitCode.rawValue, 0)
        assertEquals(root.layoutDescription, .h_master_stack([.window(1), .window(2)]))
    }

    func testMoveDeepStackWindowToMaster() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            TestWindow.new(id: 1, parent: $0) // Master
            TestWindow.new(id: 2, parent: $0) // Stack 1
            TestWindow.new(id: 3, parent: $0) // Stack 2
        }

        assertEquals(Window.get(byId: 3)?.focusWindow(), true)

        await parseCommand("move-node-to-master").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(root.layoutDescription, .h_master_stack([.window(3), .window(1), .window(2)]))
    }

    func testFloatingWindow_fails() async {
        let workspace = Workspace.get(byName: name)
        workspace.floatingWindowsContainer.apply {
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
        }

        let result = await parseCommand("move-node-to-master").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(result.exitCode.rawValue, 2)
        assertEquals(workspace.floatingWindows.map(\.windowId), [1])
    }

    func testNoFocusedWindow_fails() async {
        let result = await parseCommand("move-node-to-master").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(result.exitCode.rawValue, 2)
        assertEquals(result.stderr, [noWindowIsFocused])
    }
}
