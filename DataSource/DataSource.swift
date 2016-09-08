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
    func configureWithItem(_ item: Item, indexPath: IndexPath)
}

open class DataSource<Element: Item>: NSObject, UITableViewDataSource, UICollectionViewDataSource, MutableCollection {

    fileprivate var sections: [Section<Element>] = []
    fileprivate var tableView: UITableView?
    fileprivate weak var tableDelegate: TableViewDataSourceDelegate?
    fileprivate var collectionView: UICollectionView?
    fileprivate weak var collectionDelegate: CollectionViewDataSourceDelegate?
    fileprivate var configuring: Bool = false

    override public init() {

    }

    // MARK - Configure the data source

    /**
    Configure the data source with the given table view and delegate. This method may only be called once.

    - parameter aTableView: The table view.
    - parameter delegate:   The delegate.
    */
    open func configure(tableView aTableView: UITableView, delegate: TableViewDataSourceDelegate? = nil) {
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
    open func configure(collectionView aCollectionView: UICollectionView, delegate: CollectionViewDataSourceDelegate? = nil) {
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
    open func appendSection(_ section: Section<Element>) {
        sections.append(section)
    }

    /**
     Insert a new section at the given index.

     - parameter section: The section to be inserted.
     - parameter index:   The index at which the section should be inserted.
     */
    open func insertSection(_ section: Section<Element>, atIndex index: Int) {
        sections.insert(section, at: index)
    }

    /**
     Remove a section at the given index.

     - parameter index: The index from which to remove a section.

     - returns: The section that was removed.
     */
    open func removeSectionAtIndex(_ index: Int) -> Section<Element> {
        if index < sections.count {
            return sections.remove(at: index)
        } else {
            fatalError("The index \(index) is out of bounds.")
        }
    }

    /**
     Remove all existing sections.
     */
    open func removeAllSections() {
        sections.removeAll()
    }

    /**
     Return the item at the given index path, or nil.

     - parameter indexPath: The index path.

     - returns: The item at the given index path, or nil.
     */
    open func itemForIndexPath(_ indexPath: IndexPath) -> Item? {
        if let section = sectionAtIndex((indexPath as IndexPath).section) , (indexPath as IndexPath).row < section.count {
            return section[(indexPath as IndexPath).row]
        }

        return nil
    }

    /// Returns the total number of items, across all sections, in the data source.
    open var totalNumberOfItems: Int {
        return sections.reduce(0) { total, section in
            return total + section.count
        }
    }

    /**
     Returns the section at the given index, or nil.

     - parameter index: The index.

     - returns: The section at the given index, or nil.
     */
    open func sectionAtIndex(_ index: Int) -> Section<Element>? {
        return index < sections.count ? sections[index] : nil
    }

    // MARK: - Table registrations

    /**
    Register a table cell class for the given cell type. This method may only be called from with in the registerCells.

    - parameter cellType:  The cell type (reuse identifier).
    - parameter cellClass: The cell class.
    */
    open func registerTableCell(cellType: Int, cellClass: AnyClass) {
        guard configuring else {
            fatalError("\(#function) may only be called from the registerCells method.")
        }

        guard let tableView = tableView else {
            fatalError("\(#function) may only be called if the data source is configured to use a table view.")
        }

        tableView.register(cellClass, forCellReuseIdentifier: String(cellType))
    }

    /**
     Register a view class for the given view type. This method may only be called from with in the registerCells.

     - parameter viewType:  The view type (reuse identifier).
     - parameter viewClass: The view class.
     */
    open func registerTableHeaderFooterView(viewType: Int, viewClass: AnyClass) {
        guard configuring else {
            fatalError("\(#function) may only be called from the registerCells method.")
        }

        guard let tableView = tableView else {
            fatalError("\(#function) may only be called if the data source is configured to use a table view.")
        }

        tableView.register(viewClass, forHeaderFooterViewReuseIdentifier: String(viewType))
    }
    
    // MARK: - Collection registrations

    /**
     Register a collection cell class for the given cell type. This method may only be called from with in the registerCells.

     - parameter cellType:  The cell type (reuse identifier).
     - parameter cellClass: The cell class.
     */
    open func registerCollectionCell(cellType: Int, cellClass: AnyClass) {
        guard configuring else {
            fatalError("\(#function) may only be called from the registerCells method.")
        }

        guard let collectionView = collectionView else {
            fatalError("\(#function) may only be called if the data source is configured to use a collection view.")
        }

        collectionView.register(cellClass, forCellWithReuseIdentifier: String(cellType))
    }

    // MARK: - UITableViewDataSource methods

    open func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionAtIndex(section)?.count ?? 0
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let item = itemForIndexPath(indexPath) else {
            fatalError("There was no item for index path \(indexPath)")
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: String(item.cellType), for: indexPath)

        tableDelegate?.configure(cell: cell, atIndexPath: indexPath)

        if let cell = cell as? CellConfigurationDelegate {
            cell.configureWithItem(item, indexPath: indexPath)
        }

        return cell
    }

    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionAtIndex(section)?.headerTitle
    }

    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionAtIndex(section)?.footerTitle
    }

    // MARK: - UICollectionViewDataSource methods

    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionAtIndex(section)?.count ?? 0
    }

    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let item = itemForIndexPath(indexPath) else {
            fatalError("There was no item for index path \(indexPath)")
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(item.cellType), for: indexPath)

        collectionDelegate?.configure(cell: cell, atIndexPath: indexPath)

        if let cell = cell as? CellConfigurationDelegate {
            cell.configureWithItem(item, indexPath: indexPath)
        }

        return cell
    }

    // MARK: - Reloader

    /**
    Trigger a data reload.
    */
    open func reloadData() {
        if let tableView = tableView {
            tableView.reloadData()
        } else if let collectionView = collectionView {
            collectionView.reloadData()
        }
    }

    /**
     Perform multiple insert/add/remove operations as a group.

     - parameter updates: actions to group
     */
    open func performUpdates(_ updates: @escaping () -> ()) {
        if let tableView = tableView {
            tableView.beginUpdates()
            updates()
            tableView.endUpdates()
        } else if let collectionView = collectionView {
            collectionView.performBatchUpdates(updates, completion: nil)
        }
    }

    /**
     Reload the sepcified rows. For table views, the provided animation effect will be applied.

     - parameter indexPaths: index paths to reload
     - parameter animation:  animation effect
     */
    open func reloadIndexPaths(_ indexPaths: [IndexPath], animation: UITableViewRowAnimation = .automatic) {
        if let tableView = tableView {
            tableView.reloadRows(at: indexPaths, with: animation)
        } else if let collectionView = collectionView {
            collectionView.reloadItems(at: indexPaths)
        }
    }

    /**
     Reload the sepcified sections. For table views, the provided animation effect will be applied.

     - parameter sections: sections to reload
     - parameter animation:  animation effect
     */
    open func reloadSections(_ sections: IndexSet, animation: UITableViewRowAnimation = .automatic) {
        if let tableView = tableView {
            tableView.reloadSections(sections, with: animation)
        } else if let collectionView = collectionView {
            collectionView.reloadSections(sections)
        }
    }

    /**
     Insert rows at the specified index paths. For table views, the provided animation effect will be applied.

     - parameter indexPaths: rows to insert
     - parameter animation:  animation effect
     */
    open func insertRowsAtIndexPaths(_ indexPaths: [IndexPath], animation: UITableViewRowAnimation = .automatic) {
        if let tableView = tableView {
            tableView.insertRows(at: indexPaths, with: animation)
        } else if let collectionView = collectionView {
            collectionView.insertItems(at: indexPaths)
        }
    }

    /**
     Delete rows at the specified index paths. For table views, the provided animation effect will be applied.

     - parameter indexPaths: rows to delete
     - parameter animation:  animation effect
     */
    open func deleteRowsAtIndexPaths(_ indexPaths: [IndexPath], animation: UITableViewRowAnimation = .automatic) {
        if let tableView = tableView {
            tableView.deleteRows(at: indexPaths, with: animation)
        } else if let collectionView = collectionView {
            collectionView.deleteItems(at: indexPaths)
        }
    }

    /**
     Insert sections at the specified indexes. For table views, the provided animation effect will be applied.

     - parameter sections: sections to insert
     - parameter animation:  animation effect
     */
    open func insertSections(_ sections: IndexSet, animation: UITableViewRowAnimation = .automatic) {
        if let tableView = tableView {
            tableView.insertSections(sections, with: animation)
        } else if let collectionView = collectionView {
            collectionView.insertSections(sections)
        }
    }

    /**
     Insert sections at the specified indexes. For table views, the provided animation effect will be applied.

     - parameter sections: sections to insert
     - parameter animation:  animation effect
     */
    open func deleteSections(_ sections: IndexSet, animation: UITableViewRowAnimation = .automatic) {
        if let tableView = tableView {
            tableView.deleteSections(sections, with: animation)
        } else if let collectionView = collectionView {
            collectionView.deleteSections(sections)
        }
    }

    // MARK: - SequenceType

    open func makeIterator() -> IndexingIterator<[Section<Element>]> {
        return sections.makeIterator()
    }

    // MARK: - Indexable

    public typealias Index = Int

    open var startIndex: Index {
        return sections.startIndex
    }

    open var endIndex: Index {
        return sections.endIndex
    }

    open subscript(position: Index) -> Section<Element> {
        get {
            return sections[position]
        }
        set {
            sections[position] = newValue
        }
    }

    // MARK: - MutableIndexable

    public func index(after i: Int) -> Int {
        return sections.index(after: i)
    }
}
