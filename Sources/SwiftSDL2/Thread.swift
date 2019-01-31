//
//  Thread.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/13.
//

import CSDL2

// MARK: - ThreadPriority

public typealias ThreadPriority = SDL_ThreadPriority

extension ThreadPriority {
  public static let low = SDL_THREAD_PRIORITY_LOW
  public static let normale = SDL_THREAD_PRIORITY_NORMAL
  public static let high = SDL_THREAD_PRIORITY_HIGH
}

// MARK: - Thread

public typealias ThreadId = SDL_threadID
public typealias ThreadFunction = SDL_ThreadFunction

public final class Thread {
  /// the function to call in the new thread
  private let fn: ThreadFunction
  /// the name of the thread
  private let name: String?
  /// a pointer that is passed to fn
  private let data: UnsafeMutableRawPointer?
  /// an opaque pointer to the new thread object
  private var threadPtr: OpaquePointer!

  public init(fn: @escaping ThreadFunction, name: String? = nil, data: UnsafeMutableRawPointer? = nil) {
    self.fn = fn
    self.name = name
    self.data = data
  }

  /// The thread identifier for the current thread.
  public var threadId: ThreadId {
    return SDL_ThreadID()
  }

  public func start() {
    threadPtr = SDL_CreateThread(fn, name, data)
    precondition(threadPtr != nil, "SDL_CreateThread")
  }

  /// Wait for a thread to finish. Threads that haven't been detached will
  /// remain (as a "zombie") until this function cleans them up. Not doing so
  /// is a resource leak.
  ///
  /// Once a thread has been cleaned up through this function, the SDL_Thread
  /// that references it becomes invalid and should not be referenced again.
  /// As such, only one thread may call SDL_WaitThread() on another.
  ///
  /// You may not wait on a thread that has been used in a call to
  /// SDL_DetachThread(). Use either that function or this one, but not
  /// both, or behavior is undefined.
  ///
  /// - Returns: The return code for the thread function.
  public func wait() -> Int {
    var status = 0 as Int32
    SDL_WaitThread(threadPtr, &status)
    return Int(status)
  }

  /// A thread may be "detached" to signify that it should not remain until
  /// another thread has called SDL_WaitThread() on it. Detaching a thread
  /// is useful for long-running threads that nothing needs to synchronize
  /// with or further manage. When a detached thread is done, it simply
  /// goes away.
  ///
  /// There is no way to recover the return code of a detached thread. If you
  /// need this, don't detach the thread and instead use SDL_WaitThread().
  ///
  /// Once a thread is detached, you should usually assume the SDL_Thread isn't
  /// safe to reference again, as it will become invalid immediately upon
  /// the detached thread's exit, instead of remaining until someone has called
  /// SDL_WaitThread() to finally clean it up. As such, don't detach the same
  /// thread more than once.
  ///
  /// If a thread has already exited when passed to SDL_DetachThread(), it will
  /// stop waiting for a call to SDL_WaitThread() and clean up immediately.
  /// It is not safe to detach a thread that might be used with SDL_WaitThread().
  ///
  /// You may not call SDL_WaitThread() on a thread that has been detached.
  /// Use either that function or this one, but not both, or behavior is
  /// undefined.
  public func detach() {
    SDL_DetachThread(threadPtr)
  }
}
