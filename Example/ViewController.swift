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
import DataSource

class ViewController: UITableViewController, TableViewDataSourceCellConfigurationDelegate {

    let dataSource = DataSource<DataItem>()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configure(tableView: tableView, configurationDelegate: self)

        // Verbosely create a section
        var item1 = DataItem()
        item1.title = "Item 1"
        var item2 = DataItem()
        item2.title = "Item 2"
        var item3 = DataItem()
        item3.title = "Item 3"
        let section1 = Section(items: [item1, item2, item3])
        dataSource.appendSection(section1)

        // Through the magic (evil?) of swift, the above code can be identically acheived like this:
        dataSource.appendSection(["Item 1", "Item 2", "Item 3"])

        // Now let's use a custom cell class

        // First, register the class with the appropriate cell type
        dataSource.registerTableCell(cellType: 1, cellClass: CustomCellClass.self)

        let fancyItems: [DataItem] = (1...3).map {
            var item = DataItem()
            item.title = "Item \($0)"
            item.subtitle = "Subtitle \($0)"
            item.cellType = 1 // Don't forget to set the cell type
            return item
        }

        var section2 = Section(items: fancyItems)
        section2.headerTitle = "custom cells!" // set a header if you'd like
        dataSource.appendSection(section2)
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let item = dataSource.itemForIndexPath(indexPath) else {
            return
        }

        cell.textLabel?.text = item.title
    }

}

class CustomCellClass: UITableViewCell, CellConfigurationDelegate {

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configureWithItem(item: Item, indexPath: NSIndexPath) {
        // This method is performed AFTER the viewController's
        // equivalent `configureCell` method and can allow for further customization.
        textLabel?.text = item.title?.uppercaseString
        detailTextLabel?.text = item.subtitle
        detailTextLabel?.textColor = .lightGrayColor()
    }

}

