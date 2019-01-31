//
//  SDLError.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

public struct SDLError: Error, Equatable {
  public let reason: String

  public init(reason: String) {
    self.reason = reason
  }

  public init() {
    self.reason = String(cString: SDL_GetError()!)
  }
}

extension SDLError: CustomStringConvertible {

  public var description: String {
    return reason
  }
}

func abortIfFail(_ code: Int32, function: String) {
  if code != 0 {
    fatalError("\(function): \(String(cString: SDL_GetError())!)")
  }
}

func throwIfFail(_ code: Int32, predicate: (Int32) -> Bool = { $0 < 0 }) throws {
  if predicate(code) {
    throw SDLError()
  }
}
