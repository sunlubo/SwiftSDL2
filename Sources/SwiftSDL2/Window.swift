//
//  Window.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

// MARK: - Window

public final class Window {
  let cWindowPtr: OpaquePointer

  /// Create a window with the specified position, dimensions, and flags.
  ///
  /// If the window is created with the `Flag.allowHighDPI` flag, its size
  /// in pixels may differ from its size in screen coordinates on platforms with
  /// high-DPI support (e.g. iOS and Mac OS X). Use `SDL_GetWindowSize()` to query
  /// the client area's size in screen coordinates, and `SDL_GL_GetDrawableSize()`,
  /// `SDL_Vulkan_GetDrawableSize()`, or `SDL_GetRendererOutputSize()` to query the
  /// drawable size in pixels.
  ///
  /// If the window is created with any of the `Flag.openGL` or `Flag.vulkan` flags,
  /// then the corresponding LoadLibrary function (SDL_GL_LoadLibrary or SDL_Vulkan_LoadLibrary)
  /// is called and the corresponding UnloadLibrary function is called by SDL_DestroyWindow().
  ///
  /// If `Flag.vulkan` is specified and there isn't a working Vulkan driver,
  /// `SDL_CreateWindow()` will fail because `SDL_Vulkan_LoadLibrary()` will fail.
  ///
  /// - Note: On non-Apple devices, SDL requires you to either not link to the Vulkan loader
  ///   or link to a dynamic library version. This limitation may be removed in a future version of SDL.
  ///
  /// - Parameters:
  ///   - title: The title of the window, in UTF-8 encoding.
  ///   - x: The x position of the window, `Position.centered`, or `Position.undefined`.
  ///   - y: The y position of the window, `Position.centered`, or `Position.undefined`.
  ///   - width: The width of the window, in screen coordinates.
  ///   - height: The height of the window, in screen coordinates.
  ///   - flags: The flags for the window, a mask of any of the following:
  ///     - `Flag.fullscreen`
  ///     - `Flag.openGL`
  ///     - `Flag.hidden`
  ///     - `Flag.borderless`
  ///     - `Flag.resizable`
  ///     - `Flag.maximized`
  ///     - `Flag.minimized`
  ///     - `Flag.inputGrabbed`
  ///     - `Flag.allowHighDPI`
  ///     - `Flag.vulkan`
  public init(
    title: String,
    x: Int = Position.centered, y: Int = Position.centered,
    width: Int, height: Int,
    flags: Flag
  ) throws {
    guard let ptr = SDL_CreateWindow(
      title,
      Int32(x), Int32(y),
      Int32(width), Int32(height),
      flags.rawValue
    ) else {
      throw SDLError()
    }
    self.cWindowPtr = ptr
  }

  deinit {
    SDL_DestroyWindow(cWindowPtr)
  }

  /// The title of a window.
  public var title: String {
    get { return String(cString: SDL_GetWindowTitle(cWindowPtr)) }
    set { SDL_SetWindowTitle(cWindowPtr, title) }
  }

  /// The size of a window's client area.
  public var size: Size {
    get {
      var w = 0 as Int32
      var h = 0 as Int32
      SDL_GetWindowSize(cWindowPtr, &w, &h)
      return Size(width: w, height: h)
    }
    set { SDL_SetWindowSize(cWindowPtr, Int32(newValue.width), Int32(newValue.height)) }
  }

  /// The minimum size of a window's client area.
  public var minimumSize: Size {
    get {
      var w = 0 as Int32
      var h = 0 as Int32
      SDL_GetWindowMinimumSize(cWindowPtr, &w, &h)
      return Size(width: w, height: h)
    }
    set { SDL_SetWindowMinimumSize(cWindowPtr, Int32(newValue.width), Int32(newValue.height)) }
  }

  /// The maximum size of a window's client area.
  public var maximumSize: Size {
    get {
      var w = 0 as Int32
      var h = 0 as Int32
      SDL_GetWindowMaximumSize(cWindowPtr, &w, &h)
      return Size(width: w, height: h)
    }
    set { SDL_SetWindowMaximumSize(cWindowPtr, Int32(newValue.width), Int32(newValue.height)) }
  }

  /// The position of a window.
  public var position: Point {
    get {
      var x = 0 as Int32
      var y = 0 as Int32
      SDL_GetWindowPosition(cWindowPtr, &x, &y)
      return Point(x: x, y: y)
    }
    set { SDL_SetWindowPosition(cWindowPtr, newValue.x, newValue.y) }
  }

  /// The window's fullscreen state.
  public var isFullscreen: Bool {
    get { return flags.contains(.fullscreenDesktop) }
    set { SDL_SetWindowFullscreen(cWindowPtr, newValue ? Flag.fullscreenDesktop.rawValue : 0) }
  }

  /// The border state of a window.
  public var isBorderless: Bool {
    get { return flags.contains(.borderless) }
    set { SDL_SetWindowBordered(cWindowPtr, newValue ? SDL_FALSE : SDL_TRUE) }
  }

  /// The user-resizable state of a window.
  public var isResizable: Bool {
    get { return flags.contains(.resizable) }
    set { SDL_SetWindowResizable(cWindowPtr, newValue ? SDL_TRUE : SDL_FALSE) }
  }

  /// Get the pixel format associated with the window.
  public var pixelFormat: UInt32 {
    return SDL_GetWindowPixelFormat(cWindowPtr)
  }

  /// The window flags.
  public var flags: Flag {
    return Flag(rawValue: SDL_GetWindowFlags(cWindowPtr))
  }

  /// Get the renderer associated with a window.
  public var renderer: Renderer? {
    if let ptr = SDL_GetRenderer(cWindowPtr) {
      return Renderer(cRendererPtr: ptr)
    }
    return nil
  }

  /// Get the SDL surface associated with the window.
  ///
  /// A new surface will be created with the optimal format for the window, if necessary.
  /// This surface will be freed when the window is destroyed.
  ///
  /// - Note: You may not combine this with 3D or the rendering API on this window.
  public var surface: Surface? {
    if let ptr = SDL_GetWindowSurface(cWindowPtr) {
      return Surface(cSurfacePtr: ptr)
    }
    return nil
  }

  /// Copy the window surface to the screen.
  ///
  /// - Throws: SDLError
  public func updateSurface() throws {
    try throwIfFail(SDL_UpdateWindowSurface(cWindowPtr))
  }

  /// Show a window.
  public func show() {
    SDL_ShowWindow(cWindowPtr)
  }

  /// Hide a window.
  public func hide() {
    SDL_HideWindow(cWindowPtr)
  }

  /// Raise a window above other windows and set the input focus.
  public func raise() {
    SDL_RaiseWindow(cWindowPtr)
  }

  /// Make a window as large as possible.
  public func maximize() {
    SDL_MaximizeWindow(cWindowPtr)
  }

  /// Minimize a window to an iconic representation.
  public func minimize() {
    SDL_MinimizeWindow(cWindowPtr)
  }

  /// Restore the size and position of a minimized or maximized window.
  public func restore() {
    SDL_RestoreWindow(cWindowPtr)
  }
}

// MARK: - Window.Flag

extension Window {

  /// The flags on a window.
  public struct Flag: OptionSet {
    /// fullscreen window
    public static let fullscreen = Flag(rawValue: SDL_WINDOW_FULLSCREEN.rawValue)
    /// window usable with OpenGL context
    public static let openGL = Flag(rawValue: SDL_WINDOW_OPENGL.rawValue)
    /// window is visible
    public static let shown = Flag(rawValue: SDL_WINDOW_SHOWN.rawValue)
    /// window is not visible
    public static let hidden = Flag(rawValue: SDL_WINDOW_HIDDEN.rawValue)
    /// no window decoration
    public static let borderless = Flag(rawValue: SDL_WINDOW_BORDERLESS.rawValue)
    /// window can be resized
    public static let resizable = Flag(rawValue: SDL_WINDOW_RESIZABLE.rawValue)
    /// window is minimized
    public static let minimized = Flag(rawValue: SDL_WINDOW_MAXIMIZED.rawValue)
    /// window is maximized
    public static let maximized = Flag(rawValue: SDL_WINDOW_MAXIMIZED.rawValue)
    /// window has grabbed input focus
    public static let inputGrabbed = Flag(rawValue: SDL_WINDOW_INPUT_GRABBED.rawValue)
    /// window has input focus
    public static let inputFocus = Flag(rawValue: SDL_WINDOW_INPUT_FOCUS.rawValue)
    /// window has mouse focus
    public static let mouseFocus = Flag(rawValue: SDL_WINDOW_MOUSE_FOCUS.rawValue)
    /// window not created by SDL
    public static let foreign = Flag(rawValue: SDL_WINDOW_FOREIGN.rawValue)
    public static let fullscreenDesktop = Flag(rawValue: SDL_WINDOW_FULLSCREEN_DESKTOP.rawValue)
    /// window should be created in high-DPI mode if supported.
    /// On macOS NSHighResolutionCapable must be set true in the application's Info.plist for this to have any effect.
    public static let allowHighDPI = Flag(rawValue: SDL_WINDOW_ALLOW_HIGHDPI.rawValue)
    /// window has mouse captured (unrelated to INPUT_GRABBED)
    public static let mouseCapture = Flag(rawValue: SDL_WINDOW_MOUSE_CAPTURE.rawValue)
    /// window should always be above others
    public static let alwaysOnTop = Flag(rawValue: SDL_WINDOW_ALWAYS_ON_TOP.rawValue)
    /// window should not be added to the taskbar
    public static let skipTaskbar = Flag(rawValue: SDL_WINDOW_SKIP_TASKBAR.rawValue)
    /// window should be treated as a utility window
    public static let utility = Flag(rawValue: SDL_WINDOW_UTILITY.rawValue)
    /// window should be treated as a tooltip
    public static let tooltip = Flag(rawValue: SDL_WINDOW_TOOLTIP.rawValue)
    /// window should be treated as a popup menu
    public static let popupMenu = Flag(rawValue: SDL_WINDOW_POPUP_MENU.rawValue)
    /// window usable for Vulkan surface
    public static let vulkan = Flag(rawValue: SDL_WINDOW_VULKAN.rawValue)

    public let rawValue: UInt32

    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
  }
}

extension Window.Flag: CustomStringConvertible {

  public var description: String {
    var str = "["
    if contains(.fullscreen) { str += "fullscreen, " }
    if contains(.openGL) { str += "openGL, " }
    if contains(.shown) { str += "shown, " }
    if contains(.hidden) { str += "hidden, " }
    if contains(.borderless) { str += "borderless, " }
    if contains(.resizable) { str += "resizable, " }
    if contains(.resizable) { str += "resizable, " }
    if contains(.minimized) { str += "minimized, " }
    if contains(.maximized) { str += "maximized, " }
    if contains(.inputGrabbed) { str += "inputGrabbed, " }
    if contains(.inputFocus) { str += "inputFocus, " }
    if contains(.mouseFocus) { str += "mouseFocus, " }
    if contains(.foreign) { str += "foreign, " }
    if contains(.fullscreenDesktop) { str += "fullscreenDesktop, " }
    if contains(.allowHighDPI) { str += "allowHighDPI, " }
    if contains(.mouseCapture) { str += "mouseCapture, " }
    if contains(.alwaysOnTop) { str += "alwaysOnTop, " }
    if contains(.skipTaskbar) { str += "skipTaskbar, " }
    if contains(.utility) { str += "utility, " }
    if contains(.tooltip) { str += "tooltip, " }
    if contains(.popupMenu) { str += "popupMenu, " }
    if contains(.vulkan) { str += "vulkan, " }
    if str.suffix(2) == ", " {
      str.removeLast(2)
    }
    str += "]"
    return str
  }
}

// MARK: - Window.Position

extension Window {

  public enum Position {
    /// Used to indicate that the window position should be centered.
    public static let centered = Int(SDL_WINDOWPOS_CENTERED_MASK | 0)
    /// Used to indicate that you don't care what the window position is.
    public static let undefined = Int(SDL_WINDOWPOS_UNDEFINED_MASK | 0)
  }
}
