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

public protocol TableViewDataSourceDelegate: class {

    /**
    Register cells the necessary cells.
    */
    func registerCells()

    /**
    Configure a cell for display. This method is called immediately after the cell is dequeued.

    - parameter cell:      The cell to configure.
    - parameter indexPath: The index path the cell will be displayed at.
    */
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath)
}

public protocol CollectionViewDataSourceDelegate: class {

    /**
    Register cells the necessary cells.
    */
    func registerCells()

    /**
    Configure a cell for display. This method is called immediately after the cell is dequeued.

    - parameter cell:      The cell to configure.
    - parameter indexPath: The index path the cell will be displayed at.
    */
    func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath)
}

public protocol CellConfigurationDelegate {

    /**
    Configure a cell for display. When implemented, this method is called immediately after the collection/table data source's configureCell method and allows for further customization.

    - parameter item:      The model item.
    - parameter indexPath: The index path the receiver will be displayed at.
    */
    func configureWithItem(item: Item, indexPath: NSIndexPath)
}

public class DataSource<Element: Item>: NSObject, UITableViewDataSource, UICollectionViewDataSource, CollectionType, SequenceType, Indexable, MutableCollectionType {

    private var sections = [Section<Element>]()
    private var tableView: UITableView?
    private weak var tableDelegate: TableViewDataSourceDelegate?
    private var collectionView: UICollectionView?
    private weak var collectionDelegate: CollectionViewDataSourceDelegate?
    private var configuring = false

    override public init() {

    }

    // MARK - Configure the data source

    /**
    Configure the data source with the given table view and delegate. This method may only be called once.

    - parameter aTableView: The table view.
    - parameter delegate:   The delegate.
    */
    public func configure(tableView aTableView: UITableView, delegate: TableViewDataSourceDelegate? = nil) {
        guard collectionView == nil else {
            fatalError("This data source is already configured with a collection view")
        }

        guard tableView == nil else {
            fatalError("This data source is already configured")
        }

        configuring = true
        tableView = aTableView
        tableDelegate = delegate
        registerTableCell(cellType: 0, cellClass: UITableViewCell.self)
        delegate?.registerCells()
        tableView?.dataSource = self
        configuring = false
    }

    /**
    Configure the data source with the given collection view and delegate. This method may only be called once.

    - parameter aCollectionView: The collection view.
    - parameter delegate:        The delegate.
    */
    public func configure(collectionView aCollectionView: UICollectionView, delegate: CollectionViewDataSourceDelegate? = nil) {
        guard tableView == nil else {
            fatalError("This data source is already configured with a table view")
        }

        guard collectionView == nil else {
            fatalError("This data source is already configured")
        }

        configuring = true
        collectionView = aCollectionView
        collectionDelegate = delegate
        registerCollectionCell(cellType: 0, cellClass: UICollectionViewCell.self)
        delegate?.registerCells()
        collectionView?.dataSource = self
        configuring = false
    }

    // MARK - Interact with the data source

    /**
    Add a new section at the end of the data source.

    - parameter section: The section to add.
    */
    public func appendSection(section: Section<Element>) {
        sections.append(section)
    }

    /**
    Insert a new section at the given index.

    - parameter section: The section to be inserted.
    - parameter index:   The index at which the section should be inserted.
    */
    public func insertSection(section: Section<Element>, atIndex index: Int) {
        sections.insert(section, atIndex: index)
    }

    /**
    Remove a section at the given index.

    - parameter index: The index from which to remove a section.

    - returns: The section that was removed.
    */
    public func removeSectionAtIndex(index: Int) -> Section<Element> {
        if index < sections.count {
            return sections.removeAtIndex(index)
        } else {
            fatalError("The index \(index) is out of bounds.")
        }
    }

    /**
    Return the item at the given index path, or nil.

    - parameter indexPath: The index path.

    - returns: The item at the given index path, or nil.
    */
    public func itemForIndexPath(indexPath: NSIndexPath) -> Item? {
        if let section = sectionAtIndex(indexPath.section) where indexPath.row < section.count {
            return section[indexPath.row]
        }

        return nil
    }

    /// Returns the total number of items, across all sections, in the data source.
    public var totalNumberOfItems: Int {
        return sections.reduce(0) { total, section in
            return total + section.count
        }
    }

    /**
    Returns the section at the given index, or nil.

    - parameter index: The index.

    - returns: The section at the given index, or nil.
    */
    public func sectionAtIndex(index: Int) -> Section<Element>? {
        return index < sections.count ? sections[index] : nil
    }

    // MARK - Cell registration

    /**
    Register a table cell class for the given cell type. This method must only be called from with in registerCells.

    - parameter cellType:  The cell type (reuse identifier).
    - parameter cellClass: The cell class.
    */
    public func registerTableCell(cellType cellType: Int, cellClass: AnyClass) {
        guard configuring else {
            fatalError("\(__FUNCTION__) may only be called from the registerCells method.")
        }

        guard let tableView = tableView else {
            fatalError("\(__FUNCTION__) may only be called if the data source is configured to use a table view.")
        }

        tableView.registerClass(cellClass, forCellReuseIdentifier: String(cellType))
    }

    /**
    Register a view class for the given view type. This method must only be called from with in registerCells.

    - parameter viewType:  The view type (reuse identifier).
    - parameter viewClass: The view class.
    */
    public func registerTableHeaderFooterView(viewType viewType: Int, viewClass: AnyClass) {
        guard configuring else {
            fatalError("\(__FUNCTION__) may only be called from the registerCells method.")
        }

        guard let tableView = tableView else {
            fatalError("\(__FUNCTION__) may only be called if the data source is configured to use a table view.")
        }

        tableView.registerClass(viewClass, forHeaderFooterViewReuseIdentifier: String(viewType))
    }

    /**
    Register a collection cell class for the given cell type. This method must only be called from with in registerCells.

    - parameter cellType:  The cell type (reuse identifier).
    - parameter cellClass: The cell class.
    */
    public func registerCollectionCell(cellType cellType: Int, cellClass: AnyClass) {
        guard configuring else {
            fatalError("\(__FUNCTION__) may only be called from the registerCells method.")
        }

        guard let collectionView = collectionView else {
            fatalError("\(__FUNCTION__) may only be called if the data source is configured to use a collection view.")
        }

        collectionView.registerClass(cellClass, forCellWithReuseIdentifier: String(cellType))
    }

    // MARK: - UITableViewDataSource methods

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionAtIndex(section)?.count ?? 0
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let item = itemForIndexPath(indexPath) else {
            fatalError("There was no item for index path \(indexPath)")
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(String(item.cellType), forIndexPath: indexPath)

        tableDelegate?.configureCell(cell, atIndexPath: indexPath)

        if let cell = cell as? CellConfigurationDelegate {
            cell.configureWithItem(item, indexPath: indexPath)
        }

        return cell
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionAtIndex(section)?.headerTitle
    }

    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionAtIndex(section)?.footerTitle
    }

    // MARK: - UICollectionViewDataSource methods

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionAtIndex(section)?.count ?? 0
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let item = itemForIndexPath(indexPath) else {
            fatalError("There was no item for index path \(indexPath)")
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(item.cellType), forIndexPath: indexPath)

        collectionDelegate?.configureCell(cell, atIndexPath: indexPath)

        if let cell = cell as? CellConfigurationDelegate {
            cell.configureWithItem(item, indexPath: indexPath)
        }

        return cell
    }

    // MARK: - SequenceType

    public func generate() -> IndexingGenerator<[Section<Element>]> {
        return sections.generate()
    }

    // MARK: - Indexable

    public typealias Index = Int

    public var startIndex: Index {
        return sections.startIndex
    }

    public var endIndex: Index {
        return sections.endIndex
    }
    
    public subscript(position: Index) -> Section<Element> {
        get {
            return sections[position]
        }
        set {
            sections[position] = newValue
        }
    }
    
}
