@testable import AppBundle
import Common
import XCTest

@MainActor
final class MfactCommandTest: XCTestCase {
    override func setUp() async throws { setUpWorkspacesForTests() }

    func testParse() {
        assertNil(parseCommand("mfact 0.6").errorOrNil)
        assertNil(parseCommand("mfact +0.05").errorOrNil)
        assertNil(parseCommand("mfact -0.05").errorOrNil)
        assertEquals(
            parseCommand("mfact abc").errorOrNil,
            "ERROR: <number> argument must be a number",
        )
    }

    func testMfactSet() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
            TestWindow.new(id: 2, parent: $0)
        }

        let result = await parseCommand("mfact 0.7").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(result.exitCode.rawValue, 0)
        XCTAssertEqual(root.mfact, 0.7, accuracy: 0.001)
    }

    func testMfactAdd() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
            TestWindow.new(id: 2, parent: $0)
        }
        assertEquals(root.mfact, 0.5) // config.defaultMfact default

        await parseCommand("mfact +0.1").cmdOrDie.run(.defaultEnv, .emptyStdin)
        XCTAssertEqual(root.mfact, 0.6, accuracy: 0.001)
    }

    func testMfactSubtract() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
            TestWindow.new(id: 2, parent: $0)
        }

        await parseCommand("mfact -0.1").cmdOrDie.run(.defaultEnv, .emptyStdin)
        XCTAssertEqual(root.mfact, 0.4, accuracy: 0.001)
    }

    func testMfactClamp() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            $0.layout = .masterStack
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
            TestWindow.new(id: 2, parent: $0)
        }

        await parseCommand("mfact 1.5").cmdOrDie.run(.defaultEnv, .emptyStdin)
        XCTAssertEqual(root.mfact, 0.95, accuracy: 0.001)

        await parseCommand("mfact -0.9").cmdOrDie.run(.defaultEnv, .emptyStdin)
        // -0.9 relative to the already-clamped 0.95 lands below the floor, so it clamps to 0.05
        XCTAssertEqual(root.mfact, 0.05, accuracy: 0.001)
    }

    func testMfactNoopOnNonMasterStackLayout() async {
        let root = Workspace.get(byName: name).rootTilingContainer.apply {
            assertEquals(TestWindow.new(id: 1, parent: $0).focusWindow(), true)
            TestWindow.new(id: 2, parent: $0)
        }
        assertEquals(root.layout, .tiles)

        let result = await parseCommand("mfact 0.7").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(result.exitCode.rawValue, 2)
        XCTAssertEqual(root.mfact, 0.5, accuracy: 0.001) // Unchanged
    }

    func testMfactNoFocusedWindow_fails() async {
        let result = await parseCommand("mfact 0.7").cmdOrDie.run(.defaultEnv, .emptyStdin)
        assertEquals(result.exitCode.rawValue, 2)
        assertEquals(result.stderr, [noWindowIsFocused])
    }
}
