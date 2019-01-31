//
//  Pixels.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2019/1/29.
//

import CSDL2

// MARK: - Color

/// A structure that represents a color.
public typealias Color = SDL_Color

extension Color {
  public static let red = Color(r: 0xFF, g: 0x00, b: 0x00, a: 0xFF)
  public static let green = Color(r: 0x00, g: 0xFF, b: 0x00, a: 0xFF)
  public static let blue = Color(r: 0x00, g: 0x00, b: 0xFF, a: 0xFF)
  public static let white = Color(r: 0xFF, g: 0xFF, b: 0xFF, a: 0xFF)
  public static let black = Color(r: 0x00, g: 0x00, b: 0x00, a: 0xFF)

  public static var random: Color {
    let r = UInt8(arc4random() % 255)
    let g = UInt8(arc4random() % 255)
    let b = UInt8(arc4random() % 255)
    let a = UInt8(arc4random() % 255)
    return Color(r: r, g: g, b: b, a: a)
  }

  /// Maps an RGB triple to an opaque pixel value for a given pixel format.
  public func toPixel(with pixFmt: PixelFormat) -> UInt32 {
    return SDL_MapRGB(pixFmt.pixFmtPtr, r, g, b)
  }
}

// MARK: - PixelFormat

extension UInt32 {
  public static let unknown = UInt32(SDL_PIXELFORMAT_UNKNOWN)
  public static let bgr565 = UInt32(SDL_PIXELFORMAT_BGR565)
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
  var pixFmt: SDL_PixelFormat { return pixFmtPtr.pointee }

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
