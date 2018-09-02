//
//  Mutex.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/13.
//

import CSDL2

func abortIfFail(_ code: Int32, function: String) {
    if code != 0 {
        fatalError("\(function): \(String(cString: SDL_GetError())!)")
    }
}

// MARK: - Mutex

public final class Mutex {
    fileprivate let mutexPtr: OpaquePointer

    /// Create a mutex, initialized unlocked.
    public init() {
        self.mutexPtr = SDL_CreateMutex()
    }

    /// Lock the mutex.
    public func lock() {
        abortIfFail(SDL_LockMutex(mutexPtr), function: "SDL_LockMutex")
    }

    /// Try to lock the mutex.
    public func tryLock() -> Bool {
        let ret = SDL_TryLockMutex(mutexPtr)
        abortIfFail(ret, function: "SDL_TryLockMutex")
        return ret != SDL_MUTEX_TIMEDOUT
    }

    /// Unlock the mutex.
    public func unlock() {
        abortIfFail(SDL_UnlockMutex(mutexPtr), function: "SDL_UnlockMutex")
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
    public func wait() {
        abortIfFail(SDL_SemWait(semaphorePtr), function: "SDL_SemWait")
    }

    /// Variant of SDL_SemWait() with a timeout in milliseconds.
    ///
    /// - Parameter timeout: the length of the timeout in milliseconds
    /// - Returns: true if the wait succeeds
    /// - Throws: SDLError
    ///
    /// - Warning: On some platforms this function is implemented by looping with a delay of 1 ms,
    ///   and so should be avoided if possible.
    public func wait(timeout: Int) -> Bool {
        let ret = SDL_SemWaitTimeout(semaphorePtr, Uint32(timeout))
        abortIfFail(ret, function: "SDL_SemWaitTimeout")
        return ret != SDL_MUTEX_TIMEDOUT
    }

    /// Non-blocking variant of SDL_SemWait().
    ///
    /// - Returns: true if the wait succeeds
    public func tryWait() -> Bool {
        let ret = SDL_SemTryWait(semaphorePtr)
        abortIfFail(ret, function: "SDL_SemTryWait")
        return ret != SDL_MUTEX_TIMEDOUT
    }

    /// Atomically increases the semaphore's count (not blocking).
    public func post() {
        abortIfFail(SDL_SemPost(semaphorePtr), function: "SDL_SemPost")
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
    public func signal() {
        abortIfFail(SDL_CondSignal(condPtr), function: "SDL_CondSignal")
    }

    /// Restart all threads that are waiting on the condition variable.
    public func broadcast() {
        abortIfFail(SDL_CondBroadcast(condPtr), function: "SDL_CondBroadcast")
    }

    /// Wait on the condition variable, unlocking the provided mutex.
    ///
    /// The mutex is re-locked once the condition variable is signaled.
    ///
    /// - Warning: The mutex must be locked before entering this function.
    ///
    /// - Parameter mutex: the mutex used to coordinate thread access
    public func wait(mutex: Mutex) {
        abortIfFail(SDL_CondWait(condPtr, mutex.mutexPtr), function: "SDL_CondWait")
    }

    /// Wait until a condition variable is signaled or a specified amount of time has passed.
    ///
    /// - Warning: On some platforms this function is implemented by looping with a
    ///   delay of 1 ms, and so should be avoided if possible.
    ///
    /// - Parameters:
    ///   - mutex: the mutex used to coordinate thread access
    ///   - timeout: the maximum time to wait in milliseconds, or SDL_MUTEX_MAXWAIT to wait indefinitely
    /// - Returns: true if the wait succeeds
    public func wait(mutex: Mutex, timeout: Int) -> Bool {
        let ret = SDL_CondWaitTimeout(condPtr, mutex.mutexPtr, Uint32(timeout))
        abortIfFail(ret, function: "SDL_CondWaitTimeout")
        return ret != SDL_MUTEX_TIMEDOUT
    }

    deinit {
        SDL_DestroyCond(condPtr)
    }
}
