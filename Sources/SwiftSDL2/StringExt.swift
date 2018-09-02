//
//  StringExt.swift
//  SwiftSDL2
//
//  Created by sunlubo on 2018/9/1.
//

extension String {

    init?(cString: UnsafePointer<CChar>?) {
        guard let cString = cString else {
            return nil
        }
        self.init(cString: cString)
    }
}
