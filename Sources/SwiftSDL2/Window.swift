//
//  Window.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

// MARK: - WindowFlags

public typealias WindowFlags = SDL_WindowFlags

/// The flags on a window.
extension WindowFlags: OptionSet {
    /// fullscreen window
    public static let fullscreen = SDL_WINDOW_FULLSCREEN
    /// window usable with OpenGL context
    public static let openGL = SDL_WINDOW_OPENGL
    /// window is visible
    public static let shown = SDL_WINDOW_SHOWN
    /// window is not visible
    public static let hidden = SDL_WINDOW_HIDDEN
    /// no window decoration
    public static let borderless = SDL_WINDOW_BORDERLESS
    /// window can be resized
    public static let resizable = SDL_WINDOW_RESIZABLE
    /// window is minimized
    public static let minimized = SDL_WINDOW_MAXIMIZED
    /// window is maximized
    public static let maximized = SDL_WINDOW_MAXIMIZED
    /// window has grabbed input focus
    public static let inputGrabbed = SDL_WINDOW_INPUT_GRABBED
    /// window has input focus
    public static let inputFocus = SDL_WINDOW_INPUT_FOCUS
    /// window has mouse focus
    public static let mouseFocus = SDL_WINDOW_MOUSE_FOCUS
    /// window not created by SDL
    public static let foreign = SDL_WINDOW_FOREIGN
    public static let fullscreenDesktop = SDL_WINDOW_FULLSCREEN_DESKTOP
    /// window should be created in high-DPI mode if supported.
    /// On macOS NSHighResolutionCapable must be set true in the application's Info.plist for this to have any effect.
    public static let allowHighDPI = SDL_WINDOW_ALLOW_HIGHDPI
    /// window has mouse captured (unrelated to INPUT_GRABBED)
    public static let mouseCapture = SDL_WINDOW_MOUSE_CAPTURE
    /// window should always be above others
    public static let alwaysOnTop = SDL_WINDOW_ALWAYS_ON_TOP
    /// window should not be added to the taskbar
    public static let skipTaskbar = SDL_WINDOW_SKIP_TASKBAR
    /// window should be treated as a utility window
    public static let utility = SDL_WINDOW_UTILITY
    /// window should be treated as a tooltip
    public static let tooltip = SDL_WINDOW_TOOLTIP
    /// window should be treated as a popup menu
    public static let popupMenu = SDL_WINDOW_POPUP_MENU
    /// window usable for Vulkan surface
    public static let vulkan = SDL_WINDOW_VULKAN
}

public typealias WindowPosition = Int

extension WindowPosition {
    /// Used to indicate that the window position should be centered.
    public static let centered = Int(SDL_WINDOWPOS_CENTERED_MASK | 0)
    /// Used to indicate that you don't care what the window position is.
    public static let undefined = Int(SDL_WINDOWPOS_UNDEFINED_MASK | 0)
}

public final class Window {
    let windowPtr: OpaquePointer

    /// Create a window with the specified position, dimensions, and flags.
    ///
    ///  If the window is created with the SDL_WINDOW_ALLOW_HIGHDPI flag, its size
    ///  in pixels may differ from its size in screen coordinates on platforms with
    ///  high-DPI support (e.g. iOS and Mac OS X). Use SDL_GetWindowSize() to query
    ///  the client area's size in screen coordinates, and SDL_GL_GetDrawableSize(),
    ///  SDL_Vulkan_GetDrawableSize(), or SDL_GetRendererOutputSize() to query the
    ///  drawable size in pixels.
    ///
    ///  If the window is created with any of the SDL_WINDOW_OPENGL or
    ///  SDL_WINDOW_VULKAN flags, then the corresponding LoadLibrary function
    ///  (SDL_GL_LoadLibrary or SDL_Vulkan_LoadLibrary) is called and the
    ///  corresponding UnloadLibrary function is called by SDL_DestroyWindow().
    ///
    ///  If SDL_WINDOW_VULKAN is specified and there isn't a working Vulkan driver,
    ///  SDL_CreateWindow() will fail because SDL_Vulkan_LoadLibrary() will fail.
    ///
    /// - Parameters:
    ///   - title: The title of the window, in UTF-8 encoding.
    ///   - x: The x position of the window, ::SDL_WINDOWPOS_CENTERED, or ::SDL_WINDOWPOS_UNDEFINED.
    ///   - y: The y position of the window, ::SDL_WINDOWPOS_CENTERED, or ::SDL_WINDOWPOS_UNDEFINED.
    ///   - width: The width of the window, in screen coordinates.
    ///   - height: The height of the window, in screen coordinates.
    ///   - flags: The flags for the window, a mask of any of the following:
    ///     `fullscreen, openGL, hidden, borderless, resizable, maximized,
    ///     minimized, inputGrabbed, allowHighDPI, vulkan.`
    ///
    ///  - Note: On non-Apple devices, SDL requires you to either not link to the
    ///        Vulkan loader or link to a dynamic library version. This limitation
    ///        may be removed in a future version of SDL.
    public init(
        title: String,
        x: Int = .centered,
        y: Int = .centered,
        width: Int,
        height: Int,
        flags: WindowFlags
    ) {
        guard let wptr = SDL_CreateWindow(title, Int32(x), Int32(y), Int32(width), Int32(height), flags.rawValue) else {
            fatalError(String(cString: SDL_GetError()))
        }
        self.windowPtr = wptr
    }

    /// The title of a window.
    public var title: String {
        get { return String(cString: SDL_GetWindowTitle(windowPtr)) }
        set { SDL_SetWindowTitle(windowPtr, title) }
    }

    /// The size of a window's client area.
    public var size: Size {
        get {
            var w = 0 as Int32
            var h = 0 as Int32
            SDL_GetWindowSize(windowPtr, &w, &h)
            return Size(width: w, height: h)
        }
        set { SDL_SetWindowSize(windowPtr, Int32(newValue.width), Int32(newValue.height)) }
    }

    /// The position of a window.
    public var position: Point {
        get {
            var x = 0 as Int32
            var y = 0 as Int32
            SDL_GetWindowPosition(windowPtr, &x, &y)
            return Point(x: x, y: y)
        }
        set { SDL_SetWindowPosition(windowPtr, newValue.x, newValue.y) }
    }

    /// The window's fullscreen state.
    public var isFullscreen: Bool {
        get { return flags.contains(.fullscreenDesktop) }
        set { SDL_SetWindowFullscreen(windowPtr, newValue ? WindowFlags.fullscreenDesktop.rawValue : 0) }
    }

    /// The window flags.
    public var flags: WindowFlags {
        return WindowFlags(SDL_GetWindowFlags(windowPtr))
    }

    /// Get the SDL surface associated with the window.
    ///
    /// A new surface will be created with the optimal format for the window, if necessary.
    /// This surface will be freed when the window is destroyed.
    ///
    /// - Note: You may not combine this with 3D or the rendering API on this window.
    public var surface: Surface? {
        if let surfacePtr = SDL_GetWindowSurface(windowPtr) {
            return Surface(surfacePtr: surfacePtr)
        }
        return nil
    }

    /// Copy the window surface to the screen.
    ///
    /// - Throws: SDLError
    public func updateSurface() throws {
        try throwIfFail(SDL_UpdateWindowSurface(windowPtr))
    }

    /// Show a window.
    public func show() {
        SDL_ShowWindow(windowPtr)
    }

    deinit {
        SDL_DestroyWindow(windowPtr)
    }
}
