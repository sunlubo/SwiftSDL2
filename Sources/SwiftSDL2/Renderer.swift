///
//  Renderer.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2
#if canImport(QuartzCore)
import QuartzCore
#endif

// MARK: - Renderer

/// A structure that contains a rendering state.
public final class Renderer {
  let cRendererPtr: OpaquePointer

  init(cRendererPtr: OpaquePointer) {
    self.cRendererPtr = cRendererPtr
  }

  /// Create a 2D rendering context for a window.
  ///
  /// - Parameters:
  ///   - window: The window where rendering is displayed.
  ///   - index: The index of the rendering driver to initialize,
  ///     or -1 to initialize the first one supporting the requested flags.
  ///   - flags: 0, or one or more RendererFlags OR'd together.
  /// - Returns: A valid rendering context or NULL if there was an error.
  public init(window: Window, index: Int = -1, flags: Flag = .none) throws {
    guard let ptr = SDL_CreateRenderer(window.cWindowPtr, Int32(index), flags.rawValue) else {
      throw SDLError()
    }
    self.cRendererPtr = ptr
  }

  /// Create a 2D software rendering context for a surface.
  ///
  /// - Parameter surface: The surface where rendering is done.
  /// - Returns: A valid rendering context or NULL if there was an error.
  public init?(surface: Surface) {
    guard let ptr = SDL_CreateSoftwareRenderer(surface.cSurfacePtr) else {
      return nil
    }
    self.cRendererPtr = ptr
  }

  deinit {
    SDL_DestroyRenderer(cRendererPtr)
  }

  /// Get information about a rendering context.
  public var info: Info? {
    var info = SDL_RendererInfo()
    if SDL_GetRendererInfo(cRendererPtr, &info) != 0 {
      return nil
    }
    return Info(cInfo: info)
  }

  /// Get the output size in pixels of a rendering context.
  public var outputSize: Size {
    var w = 0 as Int32
    var h = 0 as Int32
    SDL_GetRendererOutputSize(cRendererPtr, &w, &h)
    return Size(width: w, height: h)
  }

  #if canImport(QuartzCore)
  /// Get the `CAMetalLayer` associated with the given Metal renderer.
  @available(OSX 10.11, *)
  public var metalLayer: CAMetalLayer? {
    return unsafeBitCast(SDL_RenderGetMetalLayer(cRendererPtr), to: CAMetalLayer.self)
  }
  #endif

  /// Get the current render target or `nil` for the default render target.
  public var target: Texture? {
    return Texture(cTexturePtr: SDL_GetRenderTarget(cRendererPtr))
  }

  /// Set a texture as the current rendering target.
  ///
  /// - Parameter target: The targeted texture, which must be created with the `Texture.Access.target` flag,
  ///   or `nil` for the default render target.
  /// - Throws: SDLError
  public func setTarget(_ target: Texture?) throws {
    try throwIfFail(SDL_SetRenderTarget(cRendererPtr, target?.cTexturePtr))
  }

  /// Copy a portion of the texture to the current rendering target.
  ///
  /// - Parameters:
  ///   - texture: The source texture.
  ///   - srcRect: The source rectangle, or `nil` for the entire texture.
  ///   - dstRect: The destination rectangle, or `nil` for the entire rendering target.
  /// - Throws: SDLError
  public func copy(texture: Texture, srcRect: Rect? = nil, dstRect: Rect? = nil) throws {
    try withUnsafePointer(to: srcRect) { srcRectPtr in
      try withUnsafePointer(to: dstRect) { dstRectPtr in
        try throwIfFail(SDL_RenderCopy(cRendererPtr, texture.cTexturePtr, srcRectPtr, dstRectPtr))
      }
    }
  }

  /// Copy a portion of the source texture to the current rendering target, rotating it by angle around the given center.
  ///
  /// - Parameters:
  ///   - texture: The source texture.
  ///   - srcRect: A pointer to the source rectangle, or NULL for the entire texture.
  ///   - dstRect:  A pointer to the destination rectangle, or NULL for the entire rendering target.
  ///   - angle: An angle in degrees that indicates the rotation that will be applied to dstrect, rotating it in a clockwise direction.
  ///   - center: A pointer to a point indicating the point around which dstrect will be rotated (if NULL, rotation will be done around dstrect.w/2, dstrect.h/2).
  ///   - flip: An SDL_RendererFlip value stating which flipping actions should be performed on the texture
  /// - Throws: SDLError
  public func copyEx(
    texture: Texture,
    srcRect: Rect? = nil,
    dstRect: Rect? = nil,
    angle: Double,
    center: Point? = nil,
    flip: Flip = .none
  ) throws {
    try withUnsafePointer(to: srcRect) { srcRectPtr in
      try withUnsafePointer(to: dstRect) { dstRectPtr in
        try withUnsafePointer(to: center) { pointPtr in
          try throwIfFail(
            SDL_RenderCopyEx(
              cRendererPtr,
              texture.cTexturePtr,
              srcRectPtr,
              dstRectPtr,
              angle,
              pointPtr,
              SDL_RendererFlip(flip.rawValue)
            )
          )
        }
      }
    }
  }

  /// Update the screen with rendering performed.
  public func present() {
    SDL_RenderPresent(cRendererPtr)
  }

  /// Get the number of 2D rendering drivers available for the current display.
  ///
  /// A render driver is a set of code that handles rendering and texture
  /// management on a particular display. Normally there is only one, but
  /// some drivers may have several available with different capabilities.
  ///
  /// - Returns:
  public static func driverCount(isCapture: Bool) -> Int {
    return Int(SDL_GetNumRenderDrivers())
  }

  /// Get information about a specific 2D rendering driver for the current display.
  ///
  /// - Parameter index: The index of the driver to query information about.
  /// - Returns: A pointer to an SDL_RendererInfo struct to be filled with information on the rendering driver.
  public static func driverInfo(at index: Int) -> Renderer.Info? {
    var info = SDL_RendererInfo()
    if SDL_GetRenderDriverInfo(Int32(index), &info) == 0 {
      return Renderer.Info(cInfo: info)
    }
    return nil
  }
}

extension Renderer {

  /// Set the color used for drawing operations (Rect, Line and Clear).
  ///
  /// - Throws: SDLError
  public func setDrawColor(_ color: Color) throws {
    try throwIfFail(SDL_SetRenderDrawColor(cRendererPtr, color.r, color.g, color.b, color.a))
  }

  /// Clear the current rendering target with the drawing color.
  ///
  /// This function clears the entire rendering target, ignoring the viewport and the clip rectangle.
  ///
  /// - Throws: SDLError
  public func clear() throws {
    try throwIfFail(SDL_RenderClear(cRendererPtr))
  }

  /// Draw a point on the current rendering target.
  ///
  /// - Parameter point: The x coordinate of the point. The y coordinate of the point.
  /// - Throws: SDLError
  public func drawPoint(_ point: Point) throws {
    try throwIfFail(SDL_RenderDrawPoint(cRendererPtr, point.x, point.y))
  }

  /// Draw multiple points on the current rendering target.
  ///
  /// - Parameter points: The points to draw.
  /// - Throws: SDLError
  public func drawPoints(_ points: [Point]) throws {
    try throwIfFail(SDL_RenderDrawPoints(cRendererPtr, points, Int32(points.count)))
  }

  /// Draw a line on the current rendering target.
  ///
  /// - Parameters:
  ///   - sp: The start point.
  ///   - ep: The end point.
  /// - Throws: SDLError
  public func drawLine(_ sp: Point, _ ep: Point) throws {
    try throwIfFail(SDL_RenderDrawLine(cRendererPtr, sp.x, sp.y, ep.x, ep.y))
  }

  /// Draw a series of connected lines on the current rendering target.
  ///
  /// - Parameter points: The points along the lines.
  /// - Throws: SDLError
  public func drawLines(_ points: [Point]) throws {
    try throwIfFail(SDL_RenderDrawLines(cRendererPtr, points, Int32(points.count)))
  }

  /// Draw a rectangle on the current rendering target.
  ///
  /// - Parameter rect: A pointer to the destination rectangle, or `nil` to outline the entire rendering target.
  /// - Throws: SDLError
  public func drawRect(_ rect: Rect?) throws {
    try withUnsafePointer(to: rect) { rectPtr in
      try throwIfFail(SDL_RenderDrawRect(cRendererPtr, rectPtr))
    }
  }

  /// Draw some number of rectangles on the current rendering target.
  ///
  /// - Parameter rects: A pointer to an array of destination rectangles.
  /// - Throws: SDLError
  public func drawRects(_ rects: [Rect]) throws {
    try throwIfFail(SDL_RenderDrawRects(cRendererPtr, rects, Int32(rects.count)))
  }

  /// Fill a rectangle on the current rendering target with the drawing color.
  ///
  /// - Parameter rect: A pointer to the destination rectangle, or `nil` for the entire rendering target.
  /// - Throws: SDLError
  public func fillRect(_ rect: Rect?) throws {
    try withUnsafePointer(to: rect) { rectPtr in
      try throwIfFail(SDL_RenderFillRect(cRendererPtr, rectPtr))
    }
  }

  /// Fill some number of rectangles on the current rendering target with the drawing color.
  ///
  /// - Parameter rects: A pointer to an array of destination rectangles.
  /// - Throws: SDLError
  public func fillRects(_ rects: [Rect]) throws {
    try throwIfFail(SDL_RenderFillRects(cRendererPtr, rects, Int32(rects.count)))
  }
}

// MARK: - Window.Flag

extension Renderer {

  /// Flags used when creating a rendering context.
  public struct Flag: OptionSet {
    /// providing no flags gives priority to available `SDL_RENDERER_ACCELERATED` renderers
    public static let none = Flag(rawValue: 0)
    /// the renderer is a software fallback
    public static let software = Flag(rawValue: SDL_RENDERER_SOFTWARE.rawValue)
    /// the renderer uses hardware acceleration
    public static let accelerated = Flag(rawValue: SDL_RENDERER_ACCELERATED.rawValue)
    /// present is synchronized with the refresh rate
    public static let presentVSync = Flag(rawValue: SDL_RENDERER_PRESENTVSYNC.rawValue)
    /// the renderer supports rendering to texture
    public static let targetTexture = Flag(rawValue: SDL_RENDERER_TARGETTEXTURE.rawValue)

    public let rawValue: UInt32

    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
  }
}

extension Renderer.Flag: CustomStringConvertible {

  public var description: String {
    var str = "["
    if contains(.none) { str += "none, " }
    if contains(.software) { str += "software, " }
    if contains(.accelerated) { str += "accelerated, " }
    if contains(.presentVSync) { str += "presentVSync, " }
    if contains(.targetTexture) { str += "targetTexture, " }
    if str.suffix(2) == ", " {
      str.removeLast(2)
    }
    str += "]"
    return str
  }
}

// MARK: - Renderer.Info

extension Renderer {

  /// Information on the capabilities of a render driver or context.
  public struct Info {
    let cInfo: SDL_RendererInfo

    init(cInfo: SDL_RendererInfo) {
      self.cInfo = cInfo
    }

    /// The name of the renderer.
    public var name: String {
      return String(cString: cInfo.name)
    }

    /// a mask of supported renderer flags
    public var flags: Renderer.Flag {
      return Renderer.Flag(rawValue: cInfo.flags)
    }

    /// The number of available texture formats.
    public var textureFormatCount: Int {
      return Int(cInfo.num_texture_formats)
    }

    /// The available texture formats.
    public var textureFormats: [UInt32] {
      return withUnsafeBytes(of: cInfo.flags) { ptr in
        return Array(ptr.bindMemory(to: UInt32.self).prefix(textureFormatCount))
      }
    }

    /// The maximum texture width.
    public var maxTextureWidth: Int {
      return Int(cInfo.max_texture_width)
    }

    /// The maximum texture height.
    public var maxTextureHeight: Int {
      return Int(cInfo.max_texture_height)
    }
  }
}

// MARK: - Renderer.Flip

extension Renderer {

  /// Flip constants for SDL_RenderCopyEx.
  public enum Flip: UInt32 {
    /// Do not flip
    case none = 0x00000000 // SDL_FLIP_NONE
    /// flip horizontally
    case horizontal = 0x00000001 // SDL_FLIP_HORIZONTAL
    /// flip vertically
    case vertical = 0x00000002 // SDL_FLIP_VERTICAL
  }
}
