//
//  Surface.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

// MARK: - Point

public typealias Point = SDL_Point

// MARK: - Size

/// A structure that contains width and height values.
public struct Size {
    public let width: Int
    public let height: Int

    public init<T: BinaryInteger>(width: T, height: T) {
        self.width = Int(width)
        self.height = Int(height)
    }
}

// MARK: - Rect

/// A structure that contains the definition of a rectangle, with the origin at the upper left.
public typealias Rect = SDL_Rect

extension Rect {

    public init(x: Int, y: Int, w: Int, h: Int) {
        self.init(x: Int32(x), y: Int32(y), w: Int32(w), h: Int32(h))
    }
}

// MARK: - Color

/// A structure that represents a color.
public typealias Color = SDL_Color

extension Color {

    /// Maps an RGB triple to an opaque pixel value for a given pixel format.
    public func toPixel(with pixFmt: PixelFormat) -> UInt32 {
        return SDL_MapRGB(pixFmt.pixFmtPtr, r, g, b)
    }
}

// MARK: - PixelFormat

extension UInt32 {
    public static let unknown = UInt32(SDL_PIXELFORMAT_UNKNOWN)
    public static let rgb24 = UInt32(SDL_PIXELFORMAT_RGB24)
    public static let bgr24 = UInt32(SDL_PIXELFORMAT_BGR24)
    public static let rgb888 = UInt32(SDL_PIXELFORMAT_RGB888)
    public static let bgr888 = UInt32(SDL_PIXELFORMAT_BGR888)
    public static let argb8888 = UInt32(SDL_PIXELFORMAT_ARGB8888)
    public static let rgba8888 = UInt32(SDL_PIXELFORMAT_RGBA8888)
    public static let abgr8888 = UInt32(SDL_PIXELFORMAT_ABGR8888)
    public static let bgra8888 = UInt32(SDL_PIXELFORMAT_BGRA8888)
    public static let rgba32 = UInt32(SDL_PIXELFORMAT_RGBA32)
    public static let bgra32 = UInt32(SDL_PIXELFORMAT_BGRA32)
    /// planar mode: Y + V + U (3 planes)
    public static let yv12 = UInt32(SDL_PIXELFORMAT_YV12)
    /// planar mode: Y + U + V (3 planes)
    public static let iyuv = UInt32(SDL_PIXELFORMAT_IYUV)
    /// packed mode: Y0+U0+Y1+V0 (1 plane)
    public static let yuy2 = UInt32(SDL_PIXELFORMAT_YUY2)
    /// packed mode: U0+Y0+V0+Y1 (1 plane)
    public static let uyvy = UInt32(SDL_PIXELFORMAT_UYVY)
    /// packed mode: Y0+V0+Y1+U0 (1 plane)
    public static let yuyu = UInt32(SDL_PIXELFORMAT_YVYU)
    /// planar mode: Y + U/V interleaved (2 planes) (>= SDL 2.0.4)
    public static let nv12 = UInt32(SDL_PIXELFORMAT_NV12)
    /// planar mode: Y + V/U interleaved (2 planes) (>= SDL 2.0.4)
    public static let nv21 = UInt32(SDL_PIXELFORMAT_NV21)

    /// Get the human readable name of a pixel format
    public var pixFmtName: String {
        return String(cString: SDL_GetPixelFormatName(self))
    }
}

/// A structure that contains pixel format information.
public struct PixelFormat {
    let pixFmtPtr: UnsafeMutablePointer<SDL_PixelFormat>
    var pixFmt: SDL_PixelFormat {
        return pixFmtPtr.pointee
    }

    public init(pixFmtPtr: UnsafeMutablePointer<SDL_PixelFormat>) {
        self.pixFmtPtr = pixFmtPtr
    }

    public var format: UInt32 {
        return pixFmt.format
    }

    /// the number of significant bits in a pixel value, eg: 8, 15, 16, 24, 32
    public var bitsPerPixel: Int {
        return Int(pixFmt.BitsPerPixel)
    }

    /// the number of bytes required to hold a pixel value, eg: 1, 2, 3, 4
    public var bytesPerPixel: Int {
        return Int(pixFmt.BytesPerPixel)
    }
}

// MARK: - Surface

/// A structure that contains a collection of pixels used in software blitting.
public final class Surface {
    let surfacePtr: UnsafeMutablePointer<SDL_Surface>
    var surface: SDL_Surface {
        return surfacePtr.pointee
    }

    public init(surfacePtr: UnsafeMutablePointer<SDL_Surface>) {
        self.surfacePtr = surfacePtr
    }

    /// the format of the pixels stored in the surface
    public var pixFmt: PixelFormat {
        return PixelFormat(pixFmtPtr: surface.format)
    }

    /// the width in pixels
    public var width: Int {
        return Int(surface.w)
    }

    /// the height in pixels
    public var height: Int {
        return Int(surface.h)
    }

    /// the length of a row of pixels in bytes
    public var pitch: Int {
        return Int(surface.pitch)
    }

    /// the pointer to the actual pixel data
    public var pixels: UnsafeMutableRawPointer {
        return surface.pixels
    }

    /// an arbitrary pointer you can set
    public var userdata: UnsafeMutableRawPointer {
        return surface.userdata
    }

    /// an SDL_Rect structure used to clip blits to the surface which can be set by SDL_SetClipRect()
    public var clipRect: Rect {
        return surface.clip_rect
    }

    /// reference count that can be incremented by the application
    public var refcount: Int {
        return Int(surface.refcount)
    }

    /// Evaluates to true if the surface needs to be locked before access.
    public func mustLock() -> Bool {
        return (Int32(surface.flags) & SDL_RLEACCEL) != 0
    }

    /// Sets up a surface for directly accessing the pixels.
    ///
    /// Between calls to lock/unlock, you can write to and read from `surface.pixels`,
    /// using the pixel format stored in `surface->format`.
    /// Once you are done accessing the surface, you should use `unlock` to release it.
    ///
    /// Not all surfaces require locking. If `mustLock` evaluates to false,
    /// then you can read and write to the surface at any time, and the pixel format
    /// of the surface will not change.
    ///
    /// No operating system or library calls should be made between lock/unlock
    /// pairs, as critical system locks may be held during this time.
    ///
    /// - Returns: true if successful, otherwise false.
    public func lock() -> Bool {
        return SDL_LockSurface(surfacePtr) == 0
    }

    public func unlock() {
        SDL_UnlockSurface(surfacePtr)
    }

    /// Performs a fast fill of the given rectangle with color.
    ///
    /// - Parameters:
    ///   - rect: the rectangle to fill, or nil to fill the entire surface
    ///   - color: the color to fill with
    /// - Throws: SDLError
    public func fillRect(_ rect: Rect?, color: Color) throws {
        var rect = rect
        try withUnsafeMutablePointer(to: &rect) { rectPtr in
            try throwIfFail(SDL_FillRect(surfacePtr, rectPtr, color.toPixel(with: pixFmt)))
        }
    }

    public func fillRects(_ rects: [Rect], color: Color) throws {
        try throwIfFail(
            SDL_FillRects(surfacePtr, rects, Int32(rects.count), color.toPixel(with: pixFmt))
        )
    }

    /// Sets the clipping rectangle for the destination surface in a blit.
    ///
    /// - Parameter rect: the clipping rectangle, or nil to disable clipping
    /// - Returns: Returns true if the rectangle intersects the surface, otherwise false
    ///   and blits will be completely clipped.
    ///
    /// - Note: Blits are automatically clipped to the edges of the source and destination surfaces.
    @discardableResult
    public func clip(_ rect: Rect?) -> Bool {
        var rect = rect
        return withUnsafeMutablePointer(to: &rect) { rectPtr in
            return SDL_SetClipRect(surfacePtr, rectPtr) == SDL_TRUE
        }
    }
}
