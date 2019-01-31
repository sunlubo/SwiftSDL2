//
//  Texture.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

// MARK: - BlendMode

/// The blend mode used in `SDL_RenderCopy()` and drawing operations.
public enum BlendMode: UInt32 {
  /// no blending
  ///
  ///     dstRGB = srcRGBA
  case none = 0x00000000 // SDL_BLENDMODE_NONE
  /// alpha blending
  ///
  ///     dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA))
  ///     dstA = srcA + (dstA * (1-srcA))
  case blend = 0x00000001 // SDL_BLENDMODE_BLEND
  /// additive blending
  ///
  ///     dstRGB = (srcRGB * srcA) + dstRGB
  ///     dstA = dstA
  case add = 0x00000002 // SDL_BLENDMODE_ADD
  /// color modulate
  ///
  ///     dstRGB = srcRGB * dstRGB
  ///     dstA = dstA
  case mod = 0x00000004 // SDL_BLENDMODE_MOD
  ///
  case invalid = 0x7FFFFFFF // SDL_BLENDMODE_INVALID
}

// MARK: - Texture

/// A structure that contains an efficient, driver-specific representation of pixel data.
public final class Texture {
  let cTexturePtr: OpaquePointer

  init(cTexturePtr: OpaquePointer) {
    self.cTexturePtr = cTexturePtr
  }

  /// Create a texture for a rendering context.
  ///
  /// The created texture is returned, or `nil` if no rendering context was active,
  /// the format was unsupported, or the width or height were out of range.
  ///
  /// - Note: The contents of the texture are not defined at creation.
  ///
  /// - Parameters:
  ///   - renderer: The renderer.
  ///   - format: The format of the texture.
  ///   - access: One of the enumerated values in `Texture.Access`.
  ///   - width: The width of the texture in pixels.
  ///   - height: The height of the texture in pixels.
  public init(
    renderer: Renderer,
    format: UInt32,
    access: Access,
    width: Int,
    height: Int
  ) throws {
    guard let ptr = SDL_CreateTexture(
      renderer.cRendererPtr, format, access.rawValue, Int32(width), Int32(height)
    ) else {
      throw SDLError()
    }
    self.cTexturePtr = ptr
  }

  /// Create a texture from an existing surface.
  ///
  /// - Note: The surface is not modified or freed by this function.
  ///
  /// - Parameters:
  ///   - renderer: The renderer.
  ///   - surface: The surface containing pixel data used to fill the texture.
  /// - Returns: The created texture is returned, or NULL on error.
  public init(renderer: Renderer, surface: Surface) throws {
    guard let ptr = SDL_CreateTextureFromSurface(renderer.cRendererPtr, surface.cSurfacePtr) else {
      throw SDLError()
    }
    self.cTexturePtr = ptr
  }

  /// Lock a portion of the texture for write-only pixel access.
  ///
  /// - Parameters:
  ///   - rect: A pointer to the rectangle to lock for access. If the rect is `nil`, the entire texture will be locked.
  ///   - pixels: This is filled in with a pointer to the locked pixels, appropriately offset by the locked area.
  ///   - pitch: This is filled in with the pitch of the locked pixels.
  /// - Throws: `SDLError` if the texture is not valid or was not created with `Access.streaming`.
  public func lock(
    rect: Rect? = nil,
    pixels: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
    pitch: inout Int32
  ) throws {
    try withUnsafePointer(to: rect) { rectPtr in
      try throwIfFail(SDL_LockTexture(cTexturePtr, rectPtr, pixels, &pitch))
    }
  }

  /// Unlock a texture, uploading the changes to video memory, if needed.
  public func unlock() {
    SDL_UnlockTexture(cTexturePtr)
  }

  /// Query the attributes of a texture.
  public func query() -> (format: UInt32, access: Access, width: Int, height: Int) {
    var f = 0 as UInt32
    var a = 0 as Int32
    var w = 0 as Int32
    var h = 0 as Int32
    SDL_QueryTexture(cTexturePtr, &f, &a, &w, &h)
    return (f, Access(rawValue: a)!, Int(w), Int(h))
  }

  /// Set the blend mode used for texture copy operations.
  ///
  /// - Parameter mode: blend mode to use for texture blending.
  /// - Throws: `SDLError` if the texture is not valid or the blend mode is not supported.
  public func setBlendMode(_ mode: BlendMode) throws {
    try throwIfFail(SDL_SetTextureBlendMode(cTexturePtr, SDL_BlendMode(mode.rawValue)))
  }

  /// Update the given texture rectangle with new pixel data.
  ///
  /// - Parameters:
  ///   - rect: an SDL_Rect structure representing the area to update, or `nil` to update the entire texture
  ///   - pixels: the raw pixel data in the format of the texture
  ///   - pitch: the number of bytes in a row of pixel data, including padding between lines
  /// - Throws: SDLError
  public func update(rect: Rect? = nil, pixels: UnsafeRawPointer, pitch: Int) throws {
    try withUnsafePointer(to: rect) { rectPtr in
      try throwIfFail(SDL_UpdateTexture(cTexturePtr, rectPtr, pixels, Int32(pitch)))
    }
  }

  /// Update a rectangle within a planar _YV12_ or _IYUV_ texture with new pixel data.
  ///
  /// - Parameters:
  ///   - rect: a pointer to the rectangle of pixels to update, or NULL to update the entire texture
  ///   - yPlane: the raw pixel data for the Y plane
  ///   - yPitch: the number of bytes between rows of pixel data for the Y plane
  ///   - uPlane: the raw pixel data for the U plane
  ///   - uPitch: the number of bytes between rows of pixel data for the U plane
  ///   - vPlane: the raw pixel data for the V plane
  ///   - vPitch: the number of bytes between rows of pixel data for the V plane
  /// - Throws: SDLError
  public func updateYUV(
    rect: Rect? = nil,
    yPlane: UnsafePointer<UInt8>, yPitch: Int,
    uPlane: UnsafePointer<UInt8>, uPitch: Int,
    vPlane: UnsafePointer<UInt8>, vPitch: Int
  ) throws {
    try withUnsafePointer(to: rect) { rectPtr in
      try throwIfFail(SDL_UpdateYUVTexture(
        cTexturePtr,
        rectPtr,
        yPlane, Int32(yPitch),
        uPlane, Int32(uPitch),
        vPlane, Int32(vPitch)
      ))
    }
  }
}

// MARK: - Texture.Access

extension Texture {

  /// The access pattern allowed for a texture.
  public enum Access: Int32 {
    /// Changes rarely, not lockable.
    case `static` // SDL_TEXTUREACCESS_STATIC
    /// Changes frequently, lockable.
    case streaming // SDL_TEXTUREACCESS_STREAMING
    /// Texture can be used as a render target.
    case target // SDL_TEXTUREACCESS_TARGET
  }
}
