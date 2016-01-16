/*
The MIT License (MIT)

Copyright (c) 2016 Cameron Pulsford

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/

import Foundation

import UIKit

public protocol Item {
    var title: String? { get set }
    var subtitle: String? { get set }
    var image: UIImage? { get set }
    var cellType: Int { get set }
}

public class ExtendableItem: Item {
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?
    public var cellType: Int = 0

    public init() {

    }
}

public struct DataItem: Item, StringLiteralConvertible {
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?
    public var cellType: Int = 0

    public init(title t: String? = nil, subtitle st: String? = nil, image i: UIImage? = nil, cellType ct: Int = 0) {
        title = t
        subtitle = st
        image = i
        cellType = ct
    }

    public static func Item(title: String? = nil, subtitle: String? = nil, image: UIImage? = nil, cellType: Int = 0) -> DataItem {
        return self.init(title: title, subtitle: subtitle, image: image, cellType: cellType)
    }

    // MARK: - String literal convertible

    public init(stringLiteral value: String) {
        self.init(title: value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(title: value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(title: value)
    }
}

public struct GenericDataItem<T>: Item, StringLiteralConvertible {
    public var data: T?
    public var title: String?
    public var subtitle: String?
    public var image: UIImage?
    public var cellType: Int = 0

    public init(data d: T? = nil, title t: String? = nil, subtitle st: String? = nil, image i: UIImage? = nil, cellType ct: Int = 0) {
        data = d
        title = t
        subtitle = st
        image = i
        cellType = ct
    }

    public static func Item(data: T? = nil, title: String? = nil, subtitle: String? = nil, image: UIImage? = nil, cellType: Int = 0) -> GenericDataItem<T> {
        return self.init(data: data, title: title, subtitle: subtitle, image: image, cellType: cellType)
    }

    // MARK: - String literal convertible

    public init(stringLiteral value: String) {
        self.init(title: value)
    }

    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(title: value)
    }

    public init(unicodeScalarLiteral value: String) {
        self.init(title: value)
    }
}
