//
//  PointerExt.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/9/1.
//

extension UnsafePointer {

    var mutable: UnsafeMutablePointer<Pointee> {
        return UnsafeMutablePointer(mutating: self)
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
