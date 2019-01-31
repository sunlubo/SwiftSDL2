//
//  Surface.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

/// A collection of pixels used in software blitting.
///
/// - Note: This structure should be treated as read-only, except for `pixels`,
///   which, if not NULL, contains the raw pixel data for the surface.
public final class Surface {
  let cSurfacePtr: UnsafeMutablePointer<SDL_Surface>
  var cSurface: SDL_Surface { return cSurfacePtr.pointee }

  private var freeWhenDone: Bool = false

  init(cSurfacePtr: UnsafeMutablePointer<SDL_Surface>) {
    self.cSurfacePtr = cSurfacePtr
  }

  /// Create a surface from a bmp file.
  ///
  /// - Parameter filename: The file to load.
  public init(bmp filename: String) throws {
    guard let ptr = SDL_LoadBMP_RW(SDL_RWFromFile(filename, "rb"), 1) else {
      throw SDLError()
    }
    self.cSurfacePtr = ptr
    self.freeWhenDone = true
  }

  deinit {
    if freeWhenDone {
      SDL_FreeSurface(cSurfacePtr)
    }
  }

  /// The format of the pixels stored in the surface.
  public var pixelFormat: PixelFormat {
    return PixelFormat(pixFmtPtr: cSurface.format)
  }

  /// The width in pixels.
  public var width: Int {
    return Int(cSurface.w)
  }

  /// The height in pixels.
  public var height: Int {
    return Int(cSurface.h)
  }

  /// The length of a row of pixels in bytes.
  public var pitch: Int {
    return Int(cSurface.pitch)
  }

  /// The pointer to the actual pixel data.
  public var pixels: UnsafeMutableRawPointer {
    return cSurface.pixels
  }

  /// An arbitrary pointer you can set.
  public var userdata: UnsafeMutableRawPointer {
    return cSurface.userdata
  }

  /// An `Rect` used to clip blits to the surface which can be set by `SDL_SetClipRect()`.
  public var clipRect: Rect {
    return cSurface.clip_rect
  }

  /// reference count that can be incremented by the application.
  public var refcount: Int {
    return Int(cSurface.refcount)
  }

  /// Evaluates to `true` if the surface needs to be locked before access.
  public func mustLock() -> Bool {
    return (Int32(cSurface.flags) & SDL_RLEACCEL) != 0
  }

  /// Sets up a surface for directly accessing the pixels.
  ///
  /// Between calls to lock/unlock, you can write to and read from `surface.pixels`,
  /// using the pixel format stored in `surface->format`.
  /// Once you are done accessing the surface, you should use `unlock()` to release it.
  ///
  /// Not all surfaces require locking. If `mustLock()` evaluates to `false`,
  /// then you can read and write to the surface at any time, and the pixel format
  /// of the surface will not change.
  ///
  /// No operating system or library calls should be made between lock/unlock
  /// pairs, as critical system locks may be held during this time.
  ///
  /// - Throws: `SDLError` if the surface couldn't be locked.
  public func lock() throws {
    try throwIfFail(SDL_LockSurface(cSurfacePtr))
  }

  public func unlock() {
    SDL_UnlockSurface(cSurfacePtr)
  }

  /// Performs a fast fill of the given rectangle with color.
  ///
  /// - Parameters:
  ///   - rect: the rectangle to fill, or `nil` to fill the entire surface
  ///   - color: the color to fill with
  /// - Throws: SDLError
  public func fillRect(_ rect: Rect? = nil, color: Color) throws {
    try withUnsafePointer(to: rect) { rectPtr in
      try throwIfFail(SDL_FillRect(cSurfacePtr, rectPtr, color.toPixel(with: pixelFormat)))
    }
  }

  public func fillRects(_ rects: [Rect], color: Color) throws {
    try throwIfFail(
      SDL_FillRects(cSurfacePtr, rects, Int32(rects.count), color.toPixel(with: pixelFormat))
    )
  }

  /// Sets the clipping rectangle for the destination surface in a blit.
  ///
  /// - Note: Blits are automatically clipped to the edges of the source and destination surfaces.
  ///
  /// - Parameter rect: the clipping rectangle, or `nil` to disable clipping
  /// - Returns: Returns `true` if the rectangle intersects the surface, otherwise `false`
  ///   and blits will be completely clipped.
  @discardableResult
  public func clip(_ rect: Rect?) -> Bool {
    return withUnsafePointer(to: rect) { rectPtr in
      return SDL_SetClipRect(cSurfacePtr, rectPtr) == SDL_TRUE
    }
  }

  /// Save a surface to a file.
  ///
  /// - Parameter filename: The file to write the data into.
  /// - Throws: SDLError
  public func saveBMP(to filename: String) throws {
    try throwIfFail(SDL_SaveBMP_RW(cSurfacePtr, SDL_RWFromFile(filename, "wb"), 1))
  }
}
