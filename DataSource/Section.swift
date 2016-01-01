/*
The MIT License (MIT)

Copyright (c) 2015 Cameron Pulsford

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

import UIKit

public struct Section<Element: Item>: ArrayLiteralConvertible, CollectionType, Indexable, SequenceType, MutableCollectionType  {
    public var headerTitle: String?
    public var footerTitle: String?
    private var items = [Element]()

    public var count: Int {
        return items.count
    }

    public init(arrayLiteral elements: Element...) {
        items = elements
    }

    public init(items elements: [Element]) {
        items = elements
    }

    // MARK: - SequenceType

    public func generate() -> IndexingGenerator<[Element]> {
        return items.generate()
    }

    // MARK: - Indexable

    public typealias Index = Int

    public var startIndex: Index {
        return items.startIndex
    }

    public var endIndex: Index {
        return items.endIndex
    }

    public subscript(position: Index) -> Element {
        get {
            return items[position]
        }
        set {
            items[position] = newValue
        }
    }
}
