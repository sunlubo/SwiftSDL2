//
//  SDL.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2019/1/29.
//

import CSDL2

public enum SDL {

  /// This function initializes the subsystems specified by `flags`.
  ///
  /// - Throws: SDLError
  public static func initialize(flags: InitFlag) throws {
    try throwIfFail(SDL_Init(flags.rawValue))
  }

  /// This function cleans up all initialized subsystems. You should call it upon all exit conditions.
  public static func quit() {
    SDL_Quit()
  }

  /// Set a hint with a specific priority.
  ///
  /// - Parameters:
  ///   - value: The value of the hint variable.
  ///   - name: The hint to set.
  ///   - priority: The `HintPriority` level for the hint.
  /// - Returns: `true` if successful, otherwise `false`.
  @discardableResult
  public static func setHint(
    _ value: String, forName name: String, priority: HintPriority = .normal
  ) -> Bool {
    return SDL_SetHintWithPriority(name, value, SDL_HintPriority(priority.rawValue)) == SDL_TRUE
  }

  /// Get the value of a hint.
  ///
  /// - Parameter name: the hint to query
  /// - Returns: Returns the string value of a hint or NULL if the hint isn't set.
  public static func hint(forName name: String) -> String? {
    return String(cString: SDL_GetHint(name))
  }

  public static func env(forName name: String) -> String? {
    return String(cString: SDL_getenv(name))
  }

  @discardableResult
  public static func setEnv(_ value: String, forName name: String, overwrite: Bool = true) -> Bool {
    return SDL_setenv(name, value, overwrite ? 1 : 0) == 1
  }

  /// Wait a specified number of milliseconds before returning.
  public static func delay(ms: Int) {
    SDL_Delay(UInt32(ms))
  }

  /// Returns the name of the currently initialized video driver.
  public static var currentVideoDriver: String? {
    return String(cString: SDL_GetCurrentVideoDriver())
  }

  /// Get the number of video drivers compiled into SDL.
  public static var videoDriverCount: Int {
    return Int(SDL_GetNumVideoDrivers())
  }

  /// Get the name of a built in video driver.
  ///
  /// - Note: The video drivers are presented in the order in which they are
  ///   normally checked during initialization.
  ///
  /// - Parameter index: the index of a video driver
  /// - Returns: Returns the name of the video driver with the given index.
  public static func videoDriver(at index: Int) -> String? {
    return String(cString: SDL_GetVideoDriver(Int32(index)))
  }

  /// Returns the number of available video displays.
  public static var videoDisplayCount: Int {
    return Int(SDL_GetNumVideoDisplays())
  }

  /// Get the name of a display in UTF-8 encoding.
  ///
  /// - Parameter index: the index of display from which the name should be queried
  /// - Returns: The name of a display, or `nil` for an invalid display index.
  public static func videoDisplayName(at index: Int) -> String? {
    return String(cString: SDL_GetDisplayName(Int32(index)))
  }
}

// MARK: - SDL.InitFlag

extension SDL {

  /// These are the flags which may be passed to `initSDL(flags:)`.
  /// You should specify the subsystems which you will be using in your application.
  public struct InitFlag: OptionSet {
    /// timer subsystem
    public static let timer = InitFlag(rawValue: SDL_INIT_TIMER)
    /// audio subsystem
    public static let audio = InitFlag(rawValue: SDL_INIT_AUDIO)
    /// video subsystem, automatically initializes the events subsystem
    public static let video = InitFlag(rawValue: SDL_INIT_VIDEO)
    /// joystick subsystem, automatically initializes the events subsystem
    public static let joyStick = InitFlag(rawValue: SDL_INIT_JOYSTICK)
    /// haptic (force feedback) subsystem
    public static let haptic = InitFlag(rawValue: SDL_INIT_HAPTIC)
    /// controller subsystem, automatically initializes the joystick subsystem
    public static let gameController = InitFlag(rawValue: SDL_INIT_GAMECONTROLLER)
    /// events subsystem
    public static let events = InitFlag(rawValue: SDL_INIT_EVENTS)
    /// compatibility, this flag is ignored
    public static let noParachute = InitFlag(rawValue: SDL_INIT_NOPARACHUTE)
    ///
    public static let everything = [
      .timer, .audio, .video, .events, .joyStick, .haptic, .gameController
    ] as InitFlag

    public let rawValue: UInt32

    public init(rawValue: UInt32) {
      self.rawValue = rawValue
    }
  }
}

// MARK: - SDL.Hint

extension SDL {

  public struct Hint {
    /// A variable controlling how 3D acceleration is used to accelerate the SDL screen surface.
    ///
    /// SDL can try to accelerate the SDL screen surface by using streaming textures
    /// with a 3D rendering engine. This variable controls whether and how this is done.
    ///
    /// This variable can be set to the following values:
    /// - `0`: Disable 3D acceleration.
    /// - `1`: Enable 3D acceleration, using the default renderer.
    /// - `X`: Enable 3D acceleration, using X where X is one of the valid rendering drivers.
    ///   (e.g. "direct3d", "opengl", etc.)
    ///
    /// By default SDL tries to make a best guess for each platform whether to use acceleration or not.
    public static let framebufferAcceleration = SDL_HINT_FRAMEBUFFER_ACCELERATION

    /// A variable specifying which render driver to use.
    ///
    /// If the application doesn't pick a specific renderer to use, this variable
    /// specifies the name of the preferred renderer. If the preferred renderer
    /// can't be initialized, the normal default renderer is used.
    ///
    /// This variable is case insensitive and can be set to the following values:
    /// - direct3d
    /// - opengl
    /// - opengles2
    /// - opengles
    /// - metal
    /// - software
    ///
    /// The default varies by platform, but it's the first one in the list that
    /// is available on the current platform.
    public static let renderDriver = SDL_HINT_RENDER_DRIVER

    /// A variable controlling whether the OpenGL render driver uses shaders if they are available.
    ///
    /// This variable can be set to the following values:
    /// - `0`: Disable shaders
    /// - `1`: Enable shaders
    ///
    /// By default shaders are used if OpenGL supports them.
    public static let renderOpenGLShaders = SDL_HINT_RENDER_OPENGL_SHADERS
  }

  /// Hint priorities.
  public enum HintPriority: UInt32 {
    /// low priority, used for default values
    case `default`
    /// medium priority
    case normal
    /// high priority
    case override
  }
}
