# DataSource

A quick example:

```swift
import UIKit
import DataSource

class TableViewController: UITableViewController, TableViewDataSourceDelegate {

    private let dataSource = DataSource<DataItem>()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.configure(tableView: tableView, delegate: self)
        dataSource.appendSection(["Item 1", "Item 2", "Item 3"])
    }

    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        guard let item = dataSource.itemForIndexPath(indexPath) else {
            return
        }

        cell.textLabel?.text = item.title
    }
}
```
