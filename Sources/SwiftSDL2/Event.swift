//
//  Event.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

public typealias EventType = SDL_EventType

extension EventType {
  /// Unused (do not remove)
  public static let first = SDL_FIRSTEVENT

  /* Application events */

  /// User-requested quit
  public static let quit = SDL_QUIT

  /// This last event is only for bounding internal arrays
  public static let last = SDL_LASTEVENT
}

extension UInt32 {

  public static func == (lhs: UInt32, rhs: EventType) -> Bool {
    return lhs == rhs.rawValue
  }

  public static func ~= (lhs: EventType, rhs: UInt32) -> Bool {
    return lhs.rawValue == rhs
  }
}

public enum EventState: Int32 {
  /// returns the current processing state of the specified event
  case query = -1
  /// the event will automatically be dropped from the event queue and will not be filtered
  case ignore = 0
  /// the event will be processed normally
  case enable = 1
}

public typealias Event = SDL_Event

extension Event: CustomStringConvertible {

  public var description: String {
    switch EventType(rawValue: type) {
    case .first:
      return "first"
    case .quit:
      return "quit"
    case .last:
      return "last"
    default:
      return "unknown"
    }
  }
}

public typealias EventAction = SDL_eventaction

extension EventAction {
  /// up to numevents events will be added to the back of the event queue
  public static let add = SDL_ADDEVENT
  /// up to numevents events at the front of the event queue, within the specified minimum and maximum type,
  /// will be returned and will not be removed from the queue
  public static let peek = SDL_PEEKEVENT
  /// up to numevents events at the front of the event queue, within the specified minimum and maximum type,
  /// will be returned and will be removed from the queue
  public static let get = SDL_GETEVENT
}

public enum Events {

  /// Pumps the event loop, gathering events from the input devices.
  ///
  /// This function updates the event queue and internal input device state.
  ///
  /// This should only be run in the thread that sets the video mode.
  public static func pump() {
    SDL_PumpEvents()
  }

  /// Checks the event queue for messages and optionally returns them.
  ///
  /// This function is thread-safe.
  ///
  /// - Parameters:
  ///   - events: destination buffer for the retrieved events
  ///   - count: if action is SDL_ADDEVENT, the number of events to add back to the event queue;
  ///     if action is SDL_PEEKEVENT or SDL_GETEVENT, the maximum number of events to retrieve
  ///   - action: action to take
  ///   - minType: minimum value of the event type to be considered; SDL_FIRSTEVENT is a safe choice
  ///   - maxType: maximum value of the event type to be considered; SDL_LASTEVENT is a safe choice
  /// - Returns: The number of events actually stored, or -1 if there was an error.
  /// - Throws: SDLError
  @discardableResult
  public static func peep(
    _ events: inout [Event],
    count: Int,
    action: EventAction,
    minType: UInt32 = EventType.first.rawValue,
    maxType: Uint32 = EventType.last.rawValue
  ) throws -> Int {
    precondition(events.capacity >= count, "Please allocate enough memory.")
    let ret = SDL_PeepEvents(&events, Int32(count), action, minType, maxType)
    try throwIfFail(ret)
    return Int(ret)
  }

  /// Polls for currently pending events.
  ///
  /// - Parameter event: the next event is removed from the queue and stored in that area.
  /// - Returns: true if there are any pending events, or false if there are none available.
  public static func poll() -> Event? {
    var event = Event()
    if SDL_PollEvent(&event) == 1 {
      return event
    }
    return nil
  }

  /// Add an event to the event queue.
  ///
  /// - Returns: true on success, otherwise false.
  @discardableResult
  public static func push(_ event: inout Event) -> Bool {
    return SDL_PushEvent(&event) == 1
  }

  /// Waits indefinitely for the next available event.
  ///
  /// - Returns: the next event from the queue, or nil if there was an error while waiting for events.
  @discardableResult
  public static func wait() -> Event? {
    var event = Event()
    if SDL_WaitEvent(&event) == 1 {
      return event
    }
    return nil
  }

  /// Waits until the specified timeout (in milliseconds) for the next available event.
  ///
  /// - Parameter timeout: the maximum number of milliseconds to wait for the next available event
  /// - Returns: the next event from the queue, or nil if there was an error while waiting for events.
  @discardableResult
  public static func wait(timeout: Int) -> Event? {
    var event = Event()
    if SDL_WaitEventTimeout(&event, Int32(timeout)) == 1 {
      return event
    }
    return nil
  }

  /// Set the state of processing events by type.
  ///
  /// - Parameters:
  ///   - type: the type of event
  ///   - state: how to process the event
  /// - Returns: Returns SDL_DISABLE or SDL_ENABLE, representing the processing state of the event
  ///   before this function makes any changes to it.
  @discardableResult
  public static func setEventState(type: EventType, state: EventState) -> EventState {
    return EventState(rawValue: Int32(SDL_EventState(type.rawValue, state.rawValue)))!
  }
}
