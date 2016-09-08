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

import UIKit

public protocol CellRegistrationDataSourceDelegate: class {
    /**
     Register the necessary cells.
     */
    func registerCells()
}

public extension CellRegistrationDataSourceDelegate {
    /// Default implementation.
    func registerCells() {

    }
}

public protocol TableViewDataSourceDelegate: CellRegistrationDataSourceDelegate {
    /**
     Configure a cell for display. This method is called immediately after the cell is dequeued.

     - parameter cell:      The cell to configure.
     - parameter indexPath: The index path the cell will be displayed at.
     */
    func configure(cell: UITableViewCell, atIndexPath indexPath: IndexPath)
}

public protocol CollectionViewDataSourceDelegate: CellRegistrationDataSourceDelegate {
    /**
     Configure a cell for display. This method is called immediately after the cell is dequeued.

     - parameter cell:      The cell to configure.
     - parameter indexPath: The index path the cell will be displayed at.
     */
    func configure(cell: UICollectionViewCell, atIndexPath indexPath: IndexPath)
}

public protocol CellConfigurationDelegate {
    /**
     Configure a cell for display. When implemented, this method is called immediately after the collection/table data source's configureCell method and allows for further customization.

     - parameter item:      The model item.
     - parameter indexPath: The index path the receiver will be displayed at.
     */
    func configure(withItem item: Item, indexPath: IndexPath)
}
