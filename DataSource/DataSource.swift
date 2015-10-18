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

public protocol TableViewDataSourceCellConfigurationDelegate: class {
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath)
}

public protocol CollectionViewDataSourceCellConfigurationDelegate: class {
    func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath)
}

public protocol CellConfigurationDelegate {
    func configureWithItem(item: Item, indexPath: NSIndexPath)
}

public class DataSource<Element: Item>: NSObject, UITableViewDataSource, UICollectionViewDataSource, CollectionType, SequenceType, Indexable, MutableCollectionType {

    private var sections = [Section<Element>]()
    private weak var tableView: UITableView?
    private weak var tableConfigurationDelegate: TableViewDataSourceCellConfigurationDelegate?
    private weak var collectionView: UICollectionView?
    private weak var collectionConfigurationDelegate: CollectionViewDataSourceCellConfigurationDelegate?

    override public init() {

    }

    public func configure(tableView aTableView: UITableView, configurationDelegate: TableViewDataSourceCellConfigurationDelegate? = nil) {
        guard collectionView == nil else {
            fatalError("This data source is already configured with a collection view")
        }

        tableView = aTableView
        tableConfigurationDelegate = configurationDelegate
        tableView?.dataSource = self
        registerCells()
    }

    public func configure(collectionView aCollectionView: UICollectionView, configurationDelegate: CollectionViewDataSourceCellConfigurationDelegate? = nil) {
        guard tableView == nil else {
            fatalError("This data source is already configured with a table view")
        }

        collectionView = aCollectionView
        collectionConfigurationDelegate = configurationDelegate
        collectionView?.dataSource = self
        registerCells()
    }

    public func appendSection(section: Section<Element>) {
        sections.append(section)
    }

    public func insertSection(section: Section<Element>, atIndex index: Int) {
        sections.insert(section, atIndex: index)
    }

    public func removeSectionAtIndex(index: Int) {
        if index < sections.count {
            sections.removeAtIndex(index)
        }
    }

    public func itemForIndexPath(indexPath: NSIndexPath) -> Item? {
        if let section = sectionForSection(indexPath.section) where indexPath.row < section.count {
            return section[indexPath.row]
        }

        return nil
    }

    public var totalNumberOfItems: Int {
        return sections.reduce(0) { total, section in
            return total + section.count
        }
    }

    // MARK - Cell registration

    public func registerCells() {
        if tableView != nil {
            registerTableCell(cellType: 0, cellClass: UITableViewCell.self)
        } else if collectionView != nil {
            registerCollectionCell(cellType: 0, cellClass: UICollectionViewCell.self)
        }
    }

    public func registerTableCell(cellType cellType: Int, cellClass: AnyClass) {
        tableView?.registerClass(cellClass, forCellReuseIdentifier: String(cellType))
    }

    public func registerTableHeaderFooterView(viewType viewType: Int, viewClass: AnyClass) {
        tableView?.registerClass(viewClass, forHeaderFooterViewReuseIdentifier: String(viewType))
    }

    public func registerCollectionCell(cellType cellType: Int, cellClass: AnyClass) {
        collectionView?.registerClass(cellClass, forCellWithReuseIdentifier: String(cellType))
    }

    // MARK: - UITableViewDataSource methods

    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionForSection(section)?.count ?? 0
    }

    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let item = itemForIndexPath(indexPath) else {
            fatalError("There was no item for index path \(indexPath)")
        }

        let cell = tableView.dequeueReusableCellWithIdentifier(String(item.cellType), forIndexPath: indexPath)

        tableConfigurationDelegate?.configureCell(cell, atIndexPath: indexPath)

        if let cell = cell as? CellConfigurationDelegate {
            cell.configureWithItem(item, indexPath: indexPath)
        }

        return cell
    }

    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionForSection(section)?.headerTitle
    }

    public func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionForSection(section)?.footerTitle
    }

    // MARK: - UICollectionViewDataSource methods

    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sections.count
    }

    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionForSection(section)?.count ?? 0
    }

    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        guard let item = itemForIndexPath(indexPath) else {
            fatalError("There was no item for index path \(indexPath)")
        }

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(String(item.cellType), forIndexPath: indexPath)

        collectionConfigurationDelegate?.configureCell(cell, atIndexPath: indexPath)

        if let cell = cell as? CellConfigurationDelegate {
            cell.configureWithItem(item, indexPath: indexPath)
        }

        return cell
    }

    // MARK: - Private

    private func sectionForSection(section: Int) -> Section<Element>? {
        return section < sections.count ? sections[section] : nil
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
