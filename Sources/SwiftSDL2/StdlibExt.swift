//
//  StdlibExt.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2019/1/29.
//

extension UnsafePointer {

  var mutable: UnsafeMutablePointer<Pointee> {
    return UnsafeMutablePointer(mutating: self)
  }
}

extension UnsafeBufferPointer {

  var mutable: UnsafeMutableBufferPointer<Element> {
    return UnsafeMutableBufferPointer(mutating: self)
  }
}

func withUnsafePointer<T, Result>(
  to arg: inout T?,
  _ body: (UnsafePointer<T>?) throws -> Result
) rethrows -> Result {
  if var arg = arg {
    return try withUnsafePointer(to: &arg) { try body($0) }
  } else {
    return try body(nil)
  }
}

func withUnsafePointer<T, Result>(
  to arg: T?,
  _ body: (UnsafePointer<T>?) throws -> Result
) rethrows -> Result {
  if var arg = arg {
    return try withUnsafePointer(to: &arg) { try body($0) }
  } else {
    return try body(nil)
  }
}

func withUnsafeMutablePointer<T, Result>(
  to arg: inout T?,
  _ body: (UnsafeMutablePointer<T>?) throws -> Result
) rethrows -> Result {
  if var arg = arg {
    return try withUnsafeMutablePointer(to: &arg) { try body($0) }
  } else {
    return try body(nil)
  }
}

func withUnsafeMutablePointer<T, Result>(
  to arg: T?,
  _ body: (UnsafeMutablePointer<T>?) throws -> Result
) rethrows -> Result {
  if var arg = arg {
    return try withUnsafeMutablePointer(to: &arg) { try body($0) }
  } else {
    return try body(nil)
  }
}

extension String {

  init?(cString: UnsafePointer<CChar>?) {
    guard let cString = cString else {
      return nil
    }
    self.init(cString: cString)
  }
}
