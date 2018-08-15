//
//  Texture.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

// MARK: - TextureAccess

public typealias TextureAccess = SDL_TextureAccess

extension TextureAccess: CustomStringConvertible {
    /// changes rarely, not lockable
    public static let `static` = SDL_TEXTUREACCESS_STATIC
    /// changes frequently, lockable
    public static let streaming = SDL_TEXTUREACCESS_STREAMING
    /// can be used as a render target
    public static let target = SDL_TEXTUREACCESS_TARGET

    public var description: String {
        switch self {
        case .static:
            return "static"
        case .streaming:
            return "streaming"
        case .target:
            return "target"
        default:
            return "unknown"
        }
    }
}

// MARK: - BlendMode

public typealias BlendMode = SDL_BlendMode

extension BlendMode {
    /// no blending
    ///
    ///    ```
    ///    dstRGB = srcRGBA
    ///    ```
    public static let none = SDL_BLENDMODE_NONE
    /// alpha blending
    ///
    ///    ```
    ///    dstRGB = (srcRGB * srcA) + (dstRGB * (1-srcA))
    ///    dstA = srcA + (dstA * (1-srcA))
    ///    ```
    public static let blend = SDL_BLENDMODE_BLEND
    /// additive blending
    ///
    ///    ```
    ///    dstRGB = (srcRGB * srcA) + dstRGB
    ///    dstA = dstA
    ///    ```
    public static let add = SDL_BLENDMODE_ADD
    /// color modulate
    ///
    ///    ```
    ///    dstRGB = srcRGB * dstRGB
    ///    dstA = dstA
    ///    ```
    public static let mod = SDL_BLENDMODE_MOD
}

// MARK: - Texture

/// A structure that contains an efficient, driver-specific representation of pixel data.
public final class Texture {
    let texturePtr: OpaquePointer

    init(texturePtr: OpaquePointer) {
        self.texturePtr = texturePtr
    }

    /// Create a texture for a rendering context.
    ///
    /// - Parameters:
    ///   - renderer: The renderer.
    ///   - format: The format of the texture.
    ///   - access: One of the enumerated values in ::SDL_TextureAccess.
    ///   - width: The width of the texture in pixels.
    ///   - height: The height of the texture in pixels.
    ///
    /// - Note: The contents of the texture are not defined at creation.
    public init(
        renderer: Renderer,
        format: UInt32,
        access: TextureAccess,
        width: Int,
        height: Int
    ) {
        guard let texturePtr = SDL_CreateTexture(
            renderer.rendererPtr, format, Int32(access.rawValue), Int32(width), Int32(height)
        ) else {
            fatalError(String(cString: SDL_GetError()))
        }
        self.texturePtr = texturePtr
    }

    /// Lock a portion of the texture for write-only pixel access.
    ///
    /// - Parameters:
    ///   - rect: A pointer to the rectangle to lock for access. If the rect is nil, the entire texture will be locked.
    ///   - pixels: This is filled in with a pointer to the locked pixels, appropriately offset by the locked area.
    ///   - pitch: This is filled in with the pitch of the locked pixels.
    /// - Returns: true if successful, otherwise false.
    public func lock(
        rect: Rect?,
        pixels: UnsafeMutablePointer<UnsafeMutableRawPointer?>?,
        pitch: inout Int32
    ) -> Bool {
        var rectPtr: UnsafeMutablePointer<SDL_Rect>?
        defer {
            rectPtr?.deallocate()
        }
        if let rect = rect {
            rectPtr = UnsafeMutablePointer.allocate(capacity: 1)
            rectPtr?.initialize(to: rect)
        }
        return SDL_LockTexture(texturePtr, rectPtr, pixels, &pitch) == 0
    }

    /// Unlock a texture, uploading the changes to video memory, if needed.
    public func unlock() {
        SDL_UnlockTexture(texturePtr)
    }

    /// Query the attributes of a texture.
    public func query() -> (format: UInt32, access: TextureAccess, width: Int, height: Int) {
        var f = 0 as UInt32
        var a = 0 as Int32
        var w = 0 as Int32
        var h = 0 as Int32
        SDL_QueryTexture(texturePtr, &f, &a, &w, &h)
        return (f, TextureAccess(rawValue: UInt32(a)), Int(w), Int(h))
    }

    /// Set the blend mode used for texture copy operations.
    ///
    /// - Parameter mode: blend mode to use for texture blending.
    /// - Returns: 0 on success, or -1 if the texture is not valid or the blend mode is not supported.
    @discardableResult
    public func setBlendMode(_ mode: BlendMode) -> Bool {
        return SDL_SetTextureBlendMode(texturePtr, mode) == 0
    }

    /// Update the given texture rectangle with new pixel data.
    ///
    /// - Parameters:
    ///   - rect: an SDL_Rect structure representing the area to update, or NULL to update the entire texture
    ///   - pixels: the raw pixel data in the format of the texture
    ///   - pitch: the number of bytes in a row of pixel data, including padding between lines
    /// - Throws: SDLError
    public func update(rect: Rect?, pixels: UnsafeRawPointer, pitch: Int) throws {
        var rectPtr: UnsafeMutablePointer<SDL_Rect>?
        defer {
            rectPtr?.deallocate()
        }
        if let rect = rect {
            rectPtr = UnsafeMutablePointer.allocate(capacity: 1)
            rectPtr?.initialize(to: rect)
        }
        try throwIfFail(SDL_UpdateTexture(texturePtr, rectPtr, pixels, Int32(pitch)))
    }

    /// Update a rectangle within a planar YV12 or IYUV texture with new pixel data.
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
        rect: Rect?,
        yPlane: UnsafePointer<UInt8>, yPitch: Int,
        uPlane: UnsafePointer<UInt8>, uPitch: Int,
        vPlane: UnsafePointer<UInt8>, vPitch: Int
    ) throws {
        var rectPtr: UnsafeMutablePointer<SDL_Rect>?
        defer {
            rectPtr?.deallocate()
        }
        if let rect = rect {
            rectPtr = UnsafeMutablePointer.allocate(capacity: 1)
            rectPtr?.initialize(to: rect)
        }
        try throwIfFail(
            SDL_UpdateYUVTexture(
                texturePtr, rectPtr, yPlane, Int32(yPitch), uPlane, Int32(uPitch), vPlane, Int32(vPitch)
            )
        )
    }
}
