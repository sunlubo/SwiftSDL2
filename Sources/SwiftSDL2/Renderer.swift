///
//  Renderer.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

// MARK: - RendererFlags

/// Flags used when creating a rendering context
public typealias RendererFlags = SDL_RendererFlags

extension RendererFlags {
    /// providing no flags gives priority to available SDL_RENDERER_ACCELERATED renderers
    public static let none = RendererFlags(0)
    /// the renderer is a software fallback
    public static let software = SDL_RENDERER_SOFTWARE
    /// the renderer uses hardware acceleration
    public static let accelerated = SDL_RENDERER_ACCELERATED
    /// present is synchronized with the refresh rate
    public static let presentVSync = SDL_RENDERER_PRESENTVSYNC
    /// the renderer supports rendering to texture
    public static let targetTexture = SDL_RENDERER_TARGETTEXTURE
}

/// Information on the capabilities of a render driver or context.
public struct RendererInfo {
    let sdlInfo: SDL_RendererInfo

    init(sdlInfo: SDL_RendererInfo) {
        self.sdlInfo = sdlInfo
    }

    /// the name of the renderer
    public var name: String {
        return String(cString: sdlInfo.name)
    }

    /// a mask of supported renderer flags
    public var flags: RendererFlags {
        return RendererFlags(sdlInfo.flags)
    }

    /// the number of available texture formats
    public var textureFormatCount: Int {
        return Int(sdlInfo.num_texture_formats)
    }

    /// the available texture formats
    public var textureFormats: [UInt32] {
        let list = [
            sdlInfo.texture_formats.00, sdlInfo.texture_formats.01, sdlInfo.texture_formats.02, sdlInfo.texture_formats.03,
            sdlInfo.texture_formats.04, sdlInfo.texture_formats.05, sdlInfo.texture_formats.06, sdlInfo.texture_formats.07,
            sdlInfo.texture_formats.08, sdlInfo.texture_formats.09, sdlInfo.texture_formats.10, sdlInfo.texture_formats.11,
            sdlInfo.texture_formats.12, sdlInfo.texture_formats.13, sdlInfo.texture_formats.14, sdlInfo.texture_formats.15
        ]
        return Array(list.prefix(textureFormatCount))
    }

    /// the maximum texture width
    public var maxTextureWidth: Int {
        return Int(sdlInfo.max_texture_width)
    }

    /// the maximum texture height
    public var maxTextureHeight: Int {
        return Int(sdlInfo.max_texture_height)
    }
}

// MARK: - Renderer

/// A structure that contains a rendering state.
public final class Renderer {
    let rendererPtr: OpaquePointer

    init(rendererPtr: OpaquePointer) {
        self.rendererPtr = rendererPtr
    }

    /// Create a 2D rendering context for a window.
    ///
    /// - Parameters:
    ///   - window: The window where rendering is displayed.
    ///   - index: The index of the rendering driver to initialize,
    ///     or -1 to initialize the first one supporting the requested flags.
    ///   - flags: 0, or one or more RendererFlags OR'd together.
    public init(window: Window, index: Int = -1, flags: RendererFlags = .none) {
        guard let rendererPtr = SDL_CreateRenderer(window.windowPtr, Int32(index), flags.rawValue) else {
            fatalError(String(cString: SDL_GetError()))
        }
        self.rendererPtr = rendererPtr
    }

    /// Get information about a rendering context.
    public var rendererInfo: RendererInfo? {
        var rendererInfo = SDL_RendererInfo()
        if SDL_GetRendererInfo(rendererPtr, &rendererInfo) != 0 {
            return nil
        }
        return RendererInfo(sdlInfo: rendererInfo)
    }

    /// Set a texture as the current rendering target.
    ///
    /// - Parameter target: The targeted texture, which must be created with the SDL_TEXTUREACCESS_TARGET flag,
    ///   or NULL for the default render target
    /// - Throws: SDLError
    public func setTarget(_ target: Texture?) throws {
        try throwIfFail(SDL_SetRenderTarget(rendererPtr, target?.texturePtr))
    }

    /// Set the color used for drawing operations (Rect, Line and Clear).
    ///
    /// - Throws: SDLError
    public func setDrawColor(_ color: Color) throws {
        try throwIfFail(SDL_SetRenderDrawColor(rendererPtr, color.r, color.g, color.b, color.a))
    }

    /// Clear the current rendering target with the drawing color.
    ///
    /// This function clears the entire rendering target, ignoring the viewport and the clip rectangle.
    ///
    /// - Throws: SDLError
    public func clear() throws {
        try throwIfFail(SDL_RenderClear(rendererPtr))
    }

    /// Draw a rectangle on the current rendering target.
    ///
    /// - Parameter rect: A pointer to the destination rectangle, or nil to outline the entire rendering target.
    /// - Throws: SDLError
    public func drawRect(_ rect: Rect?) throws {
        var rect = rect
        try withUnsafeMutablePointer(to: &rect) { rectPtr in
            try throwIfFail(SDL_RenderDrawRect(rendererPtr, rectPtr))
        }
    }

    /// Fill a rectangle on the current rendering target with the drawing color.
    ///
    /// - Parameter rect: A pointer to the destination rectangle, or NULL for the entire rendering target.
    /// - Throws: SDLError
    public func fillRect(_ rect: Rect?) throws {
        var rect = rect
        try withUnsafeMutablePointer(to: &rect) { rectPtr in
            try throwIfFail(SDL_RenderFillRect(rendererPtr, rectPtr))
        }
    }

    /// Copy a portion of the texture to the current rendering target.
    ///
    /// - Parameters:
    ///   - texture: The source texture.
    ///   - srcRect: A pointer to the source rectangle, or nil for the entire texture.
    ///   - dstRect: A pointer to the destination rectangle, or nil for the entire rendering target.
    /// - Throws: SDLError
    public func copy(texture: Texture?, srcRect: Rect?, dstRect: Rect?) throws {
        var srcRect = srcRect
        var dstRect = dstRect
        try withUnsafeMutablePointer(to: &srcRect) { srcRectPtr in
            try withUnsafeMutablePointer(to: &dstRect) { dstRectPtr in
                try throwIfFail(SDL_RenderCopy(rendererPtr, texture?.texturePtr, srcRectPtr, dstRectPtr))
            }
        }
    }

    /// Update the screen with rendering performed.
    public func present() {
        SDL_RenderPresent(rendererPtr)
    }

    deinit {
        SDL_DestroyRenderer(rendererPtr)
    }
}
