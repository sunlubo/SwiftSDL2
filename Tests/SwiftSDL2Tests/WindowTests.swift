//
//  WindowTests.swift
//  SwiftSDL2Tests
//
//  Created by sunlubo on 2018/8/11.
//

import XCTest
@testable import SwiftSDL2

class WindowTests: XCTestCase {

    static var allTests = [
        ("testWindowFlags", testWindowFlags)
    ]

    func testWindowFlags() {
        XCTAssertEqual(WindowFlags.fullscreen.rawValue, 0x00000001)
        XCTAssertEqual(WindowFlags.opengl.rawValue, 0x00000002)
        XCTAssertEqual(WindowFlags.shown.rawValue, 0x00000004)
        XCTAssertEqual(WindowFlags.hidden.rawValue, 0x00000008)
        XCTAssertEqual(WindowFlags.borderless.rawValue, 0x00000010)
        XCTAssertEqual(WindowFlags.resizable.rawValue, 0x00000020)
        XCTAssertEqual(WindowFlags.minimized.rawValue, 0x00000040)
        XCTAssertEqual(WindowFlags.maximized.rawValue, 0x00000080)
        XCTAssertEqual(WindowFlags.inputGrabbed.rawValue, 0x00000100)
        XCTAssertEqual(WindowFlags.inputFocus.rawValue, 0x00000200)
        XCTAssertEqual(WindowFlags.mouseFocus.rawValue, 0x00000400)
        XCTAssertEqual(WindowFlags.fullscreenDesktop.rawValue, (WindowFlags.fullscreen.rawValue | 0x00001000))
        XCTAssertEqual(WindowFlags.foreign.rawValue, 0x00000800)
        XCTAssertEqual(WindowFlags.allowHighDPI.rawValue, 0x00002000)
        XCTAssertEqual(WindowFlags.mouseCapture.rawValue, 0x00004000)
        XCTAssertEqual(WindowFlags.alwaysOnTop.rawValue, 0x00008000)
        XCTAssertEqual(WindowFlags.skipTaskbar.rawValue, 0x00010000)
        XCTAssertEqual(WindowFlags.utility.rawValue, 0x00020000)
        XCTAssertEqual(WindowFlags.tooltip.rawValue, 0x00040000)
        XCTAssertEqual(WindowFlags.popupMenu.rawValue, 0x00080000)
        XCTAssertEqual(WindowFlags.vulkan.rawValue, 0x10000000)
    }
}
