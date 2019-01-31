//
//  OpenGL.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2019/1/30.
//

import CSDL2

typealias CGLContext = SDL_GLContext

public final class GLContext {
  let cContext: CGLContext
  
  /// Create an OpenGL context for use with an OpenGL window, and make it current.
  ///
  /// - Parameter window: the window to associate with the context
  /// - Throws: SDLError
  public init(window: Window) throws {
    guard let ctx = SDL_GL_CreateContext(window.cWindowPtr) else {
      throw SDLError()
    }
    self.cContext = ctx
  }
  
  deinit {
    SDL_GL_DeleteContext(cContext)
  }
  
  /// The swap interval for the current OpenGL context.
  ///
  /// 0 for immediate updates, 1 for updates synchronized with the vertical retrace.
  /// If the system supports it, you may specify -1 to allow late swaps to happen immediately
  /// instead of waiting for the next retrace.
  public static var swapInterval: Int {
    get { return Int(SDL_GL_GetSwapInterval()) }
    set { SDL_GL_SetSwapInterval(Int32(newValue)) }
  }
  
  /// Reset all previously set OpenGL context attributes to their default values.
  public static func resetAttribute() {
    SDL_GL_ResetAttributes()
  }
  
  /// Set an OpenGL window attribute before window creation.
  ///
  /// - Parameters:
  ///   - value: the desired value for the attribute
  ///   - key: the OpenGL attribute to set
  /// - Throws: SDLError if the attribute could not be set.
  public static func setAttribute(_ value: Int32, forKey key: Attr) throws {
    try throwIfFail(SDL_GL_SetAttribute(SDL_GLattr(key.rawValue), value))
  }
  
  /// Get the actual value for an attribute from the current context.
  ///
  /// - Parameter key: the OpenGL attribute to set
  /// - Returns: a pointer filled in with the current value of attr
  /// - Throws: SDLError if the attribute could not be retrieved.
  public static func attribute(forKey key: Attr) throws -> Int32 {
    var v = 0 as Int32
    try throwIfFail(SDL_GL_GetAttribute(SDL_GLattr(key.rawValue), &v))
    return v
  }
}

extension GLContext {
  
  /// OpenGL configuration attributes
  public enum Attr: UInt32 {
    /// the minimum number of bits for the red channel of the color buffer; defaults to 3
    case SDL_GL_RED_SIZE
    /// the minimum number of bits for the green channel of the color buffer; defaults to 3
    case SDL_GL_GREEN_SIZE
    /// the minimum number of bits for the blue channel of the color buffer; defaults to 2
    case SDL_GL_BLUE_SIZE
    /// the minimum number of bits for the alpha channel of the color buffer; defaults to 0
    case SDL_GL_ALPHA_SIZE
    /// the minimum number of bits for frame buffer size; defaults to 0
    case SDL_GL_BUFFER_SIZE
    /// whether the output is single or double buffered; defaults to double buffering on
    case doubleBuffer
    /// the minimum number of bits in the depth buffer; defaults to 16
    case depthSize
    /// the minimum number of bits in the stencil buffer; defaults to 0
    case SDL_GL_STENCIL_SIZE
    /// the minimum number of bits for the red channel of the accumulation buffer; defaults to 0
    case SDL_GL_ACCUM_RED_SIZE
    /// the minimum number of bits for the green channel of the accumulation buffer; defaults to 0
    case SDL_GL_ACCUM_GREEN_SIZE
    /// the minimum number of bits for the blue channel of the accumulation buffer; defaults to 0
    case SDL_GL_ACCUM_BLUE_SIZE
    /// the minimum number of bits for the alpha channel of the accumulation buffer; defaults to 0
    case SDL_GL_ACCUM_ALPHA_SIZE
    /// whether the output is stereo 3D; defaults to off
    case SDL_GL_STEREO
    /// the number of buffers used for multisample anti-aliasing; defaults to 0
    case SDL_GL_MULTISAMPLEBUFFERS
    /// the number of samples used around the current pixel used for multisample anti-aliasing
    case SDL_GL_MULTISAMPLESAMPLES
    /// set to 1 to require hardware acceleration, set to 0 to force software rendering; defaults to allow either
    case SDL_GL_ACCELERATED_VISUAL
    /// not used (deprecated)
    case SDL_GL_RETAINED_BACKING
    /// OpenGL context major version
    case majorVersion
    /// OpenGL context minor version
    case minorVersion
    /// not used (deprecated)
    case SDL_GL_CONTEXT_EGL
    /// some combination of 0 or more of elements of the SDL_GLcontextFlag enumeration; defaults to 0
    case SDL_GL_CONTEXT_FLAGS
    /// type of GL context (Core, Compatibility, ES). See SDL_GLprofile; default value depends on platform
    case SDL_GL_CONTEXT_PROFILE_MASK
    /// OpenGL context sharing; defaults to 0
    case SDL_GL_SHARE_WITH_CURRENT_CONTEXT
    /// requests sRGB capable visual; defaults to 0 (>= SDL 2.0.1)
    case SDL_GL_FRAMEBUFFER_SRGB_CAPABLE
    /// sets context the release behavior; defaults to 1 (>= SDL 2.0.4)
    case SDL_GL_CONTEXT_RELEASE_BEHAVIOR
    ///
    case SDL_GL_CONTEXT_RESET_NOTIFICATION
    ///
    case SDL_GL_CONTEXT_NO_ERROR
  }
}

extension Window {
  
  /// Get the size of a window's underlying drawable in pixels (for use with glViewport).
  public var drawableSize: Size {
    var w = 0 as Int32
    var h = 0 as Int32
    SDL_GL_GetDrawableSize(cWindowPtr, &w, &h)
    return Size(width: w, height: h)
  }
  
  /// Swap the OpenGL buffers for a window, if double-buffering is supported.
  public func swap() {
    SDL_GL_SwapWindow(cWindowPtr)
  }
}
