//
//  SDLError.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/8/11.
//

import CSDL2

public struct SDLError: Error, Equatable, CustomStringConvertible {
    public let code: Int32

    public init(code: Int32) {
        self.code = code
    }

    public var description: String {
        return String(cString: SDL_GetError())
    }
}

func throwIfFail(_ code: Int32) throws {
    if code < 0 {
        throw SDLError(code: code)
    }
}
