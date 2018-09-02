//
//  Util.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

// MARK: - Init

public struct SDLInitFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    /// timer subsystem
    public static let timer = SDLInitFlags(rawValue: SDL_INIT_TIMER)
    /// audio subsystem
    public static let audio = SDLInitFlags(rawValue: SDL_INIT_AUDIO)
    /// video subsystem; automatically initializes the events subsystem
    public static let video = SDLInitFlags(rawValue: SDL_INIT_VIDEO)
    /// joystick subsystem; automatically initializes the events subsystem
    public static let joyStick = SDLInitFlags(rawValue: SDL_INIT_JOYSTICK)
    /// haptic (force feedback) subsystem
    public static let haptic = SDLInitFlags(rawValue: SDL_INIT_HAPTIC)
    /// controller subsystem; automatically initializes the joystick subsystem
    public static let gameController = SDLInitFlags(rawValue: SDL_INIT_GAMECONTROLLER)
    /// events subsystem
    public static let events = SDLInitFlags(rawValue: SDL_INIT_EVENTS)
    /// compatibility; this flag is ignored.
    public static let noParachute = SDLInitFlags(rawValue: SDL_INIT_NOPARACHUTE)
    public static let everything = [
        .timer, .audio, .video, .events, .joyStick, .haptic, .gameController
    ] as SDLInitFlags
}

/// This function initializes the subsystems specified by flags.
///
/// - Throws: SDLError
public func initSDL(flags: SDLInitFlags) throws {
    try throwIfFail(SDL_Init(flags.rawValue))
}

/// This function cleans up all initialized subsystems. You should call it upon all exit conditions.
public func quitSDL() {
    SDL_Quit()
}

/// Set a hint with normal priority.
///
/// - Parameters:
///   - name: the hint to set
///   - value: the value of the hint variable
/// - Returns: true if successful, otherwise false.
@discardableResult
public func setHint(name: String, value: String) -> Bool {
    return SDL_SetHint(name, value) == SDL_TRUE
}

public func getEnv(name: String) -> String? {
    return String(cString: SDL_getenv(name))
}

public func setEnv(name: String, value: String, overwrite: Bool = true) -> Bool {
    return SDL_setenv(name, value, overwrite ? 1 : 0) == 1
}

/// Wait a specified number of milliseconds before returning.
public func delay(ms: Int) {
    SDL_Delay(Uint32(ms))
}
