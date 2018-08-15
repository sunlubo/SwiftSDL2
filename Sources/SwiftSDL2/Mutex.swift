//
//  Mutex.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/13.
//

import CSDL2

// MARK: - Mutex

public final class Mutex {
    fileprivate let mutexPtr: OpaquePointer

    /// Create a mutex, initialized unlocked.
    public init() {
        self.mutexPtr = SDL_CreateMutex()
    }

    /// Lock the mutex.
    ///
    /// - Throws: SDLError
    public func lock() throws {
        try throwIfFail(SDL_LockMutex(mutexPtr))
    }

    /// Try to lock the mutex.
    ///
    /// - Throws: SDLError
    public func tryLock() throws -> Bool {
        let ret = SDL_TryLockMutex(mutexPtr)
        try throwIfFail(ret)
        return ret != SDL_MUTEX_TIMEDOUT
    }

    /// Unlock the mutex.
    ///
    /// - Throws: SDLError
    public func unlock() throws {
        try throwIfFail(SDL_UnlockMutex(mutexPtr))
    }

    deinit {
        SDL_DestroyMutex(mutexPtr)
    }
}

// MARK: - Semaphore

public final class Semaphore {
    private let semaphorePtr: OpaquePointer

    /// Create a semaphore, initialized with value.
    public init(value: Int) {
        self.semaphorePtr = SDL_CreateSemaphore(Uint32(value))
    }

    /// Returns the current count of the semaphore.
    public var value: Int {
        return Int(SDL_SemValue(semaphorePtr))
    }

    /// This function suspends the calling thread until the semaphore has a positive count.
    /// It then atomically decreases the semaphore count.
    ///
    /// - Throws: SDLError
    public func wait() throws {
        try throwIfFail(SDL_SemWait(semaphorePtr))
    }

    /// Variant of SDL_SemWait() with a timeout in milliseconds.
    ///
    /// - Parameter timeout: the length of the timeout in milliseconds
    /// - Returns: true if the wait succeeds
    /// - Throws: SDLError
    ///
    /// - Warning: On some platforms this function is implemented by looping with a delay of 1 ms,
    ///   and so should be avoided if possible.
    public func wait(timeout: Int) throws -> Bool {
        let ret = SDL_SemWaitTimeout(semaphorePtr, Uint32(timeout))
        try throwIfFail(ret)
        return ret != SDL_MUTEX_TIMEDOUT
    }

    /// Non-blocking variant of SDL_SemWait().
    ///
    /// - Returns: true if the wait succeeds
    /// - Throws: SDLError
    public func tryWait() throws -> Bool {
        let ret = SDL_SemTryWait(semaphorePtr)
        try throwIfFail(ret)
        return ret != SDL_MUTEX_TIMEDOUT
    }

    /// Atomically increases the semaphore's count (not blocking).
    public func post() throws {
        try throwIfFail(SDL_SemPost(semaphorePtr))
    }

    deinit {
        SDL_DestroySemaphore(semaphorePtr)
    }
}

// MARK: - Condition

public final class Condition {
    private let condPtr: OpaquePointer

    /// Create a condition variable.
    ///
    /// There is some discussion whether to signal the condition variable
    /// with the mutex locked or not.  There is some potential performance
    /// benefit to unlocking first on some platforms, but there are some
    /// potential race conditions depending on how your code is structured.
    ///
    /// In general it's safer to signal the condition variable while the mutex is locked.
    public init() {
        self.condPtr = SDL_CreateCond()
    }

    /// Restart one of the threads that are waiting on the condition variable.
    ///
    /// - Throws: SDLError
    public func signal() throws {
        try throwIfFail(SDL_CondSignal(condPtr))
    }

    /// Restart all threads that are waiting on the condition variable.
    ///
    /// - Throws: SDLError
    public func broadcast() throws {
        try throwIfFail(SDL_CondBroadcast(condPtr))
    }

    /// Wait on the condition variable, unlocking the provided mutex.
    ///
    /// The mutex is re-locked once the condition variable is signaled.
    ///
    /// - Parameter mutex: the mutex used to coordinate thread access
    /// - Throws: SDLError
    ///
    /// - Warning: The mutex must be locked before entering this function.
    public func wait(mutex: Mutex) throws {
        try throwIfFail(SDL_CondWait(condPtr, mutex.mutexPtr))
    }

    /// Wait until a condition variable is signaled or a specified amount of time has passed.
    ///
    /// - Parameters:
    ///   - mutex: the mutex used to coordinate thread access
    ///   - timeout: the maximum time to wait in milliseconds, or SDL_MUTEX_MAXWAIT to wait indefinitely
    /// - Returns: true if the wait succeeds
    /// - Throws: SDLError
    ///
    /// - Warning: On some platforms this function is implemented by looping with a
    ///   delay of 1 ms, and so should be avoided if possible.
    public func wait(mutex: Mutex, timeout: Int) throws -> Bool {
        let ret = SDL_CondWaitTimeout(condPtr, mutex.mutexPtr, Uint32(timeout))
        try throwIfFail(ret)
        return ret != SDL_MUTEX_TIMEDOUT
    }

    deinit {
        SDL_DestroyCond(condPtr)
    }
}
