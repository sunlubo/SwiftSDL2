//
//  Shape.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2019/1/29.
//

import CSDL2

// MARK: - Point

public typealias Point = SDL_Point

// MARK: - Size

/// A structure that contains width and height values.
public struct Size {
  public let width: Int
  public let height: Int

  public init<T: BinaryInteger>(width: T, height: T) {
    self.width = Int(width)
    self.height = Int(height)
  }
}

// MARK: - Rect

/// A structure that contains the definition of a rectangle, with the origin at the upper left.
public typealias Rect = SDL_Rect

extension Rect {

  public init(x: Int, y: Int, w: Int, h: Int) {
    self.init(x: Int32(x), y: Int32(y), w: Int32(w), h: Int32(h))
  }
}
