//
//  Timer.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/27.
//

import CSDL2

public typealias TimerID = SDL_TimerID
public typealias TimerCallback = SDL_TimerCallback

public enum Timer {
    /// Add a new timer to the pool of timers already running.
    ///
    /// - Note: The callback is run on a separate thread.
    ///
    /// - Parameters:
    ///   - timeInterval: the timer delay (ms) passed to callback
    ///   - param: a pointer that is passed to callback
    ///   - callback: the function to call when the specified interval elapses
    /// - Returns: A timer ID.
    public static func schedule(
        withTimeInterval timeInterval: Int,
        param: UnsafeMutableRawPointer? = nil,
        callback: @escaping SDL_TimerCallback
    ) -> TimerID {
        let timerId = SDL_AddTimer(UInt32(timeInterval), callback, param)
        if timerId == 0 {
            fatalError("SDL_AddTimer: \(String(cString: SDL_GetError())!)")
        }
        return timerId
    }

    /// Remove a timer knowing its ID.
    ///
    /// - Warning: It is not safe to remove a timer multiple times.
    ///
    /// - Parameter timerId: the ID of the timer to remove
    /// - Returns: A boolean value indicating success or failure.
    public static func cancel(_ timerId: TimerID) -> Bool {
        return SDL_RemoveTimer(timerId) == SDL_TRUE
    }
}
