```swift
import UIKit
import DataSource

class ViewController: UITableViewController, TableViewDataSourceDelegate {

  let dataSource = DataSource<DataItem>()

  override func viewDidLoad() {
      super.viewDidLoad()
      dataSource.configure(tableView: tableView, delegate: self)

      // Verbosely create a section
      var item1 = DataItem()
      item1.title = "Item 1"
      var item2 = DataItem()
      item2.title = "Item 2"
      var item3 = DataItem()
      item3.title = "Item 3"
      let section1 = Section(items: [item1, item2, item3])
      dataSource.append(section: section1)

      // Through the magic (evil?) of swift, the above code can be identically acheived like this:
      dataSource.append(section: ["Item 1", "Item 2", "Item 3"])

      // Now let's use a custom cell class
      // Register the cell class in the `registerCells` protocol method. (implemented below)
      let fancyItems: [DataItem] = (1...3).map {
        	var item = DataItem()
        	item.title = "Item \($0)"
        	item.subtitle = "Subtitle \($0)"
        	item.cellType = 1 // Don't forget to set the cell type
        	return item
      }

      var section2 = Section(items: fancyItems)
      section2.headerTitle = "custom cells!" // set a header if you'd like
      dataSource.append(section: section2)
  }

  func registerCells() {
      dataSource.registerTableCell(cellType: 1, cellClass: CustomCellClass.self)
  }

  func configure(cell: UITableViewCell, at indexPath: NSIndexPath) {
      guard let item = dataSource.item(at: indexPath) else { return }
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

  func configure(with item: Item, at indexPath: NSIndexPath) {
      // This method is performed AFTER the viewController's
      // equivalent `configureCell` method and can allow for further customization.
      textLabel?.text = item.title?.uppercaseString
      detailTextLabel?.text = item.subtitle
      detailTextLabel?.textColor = .lightGrayColor()
  }
}
```
