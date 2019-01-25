import UIKit

// MARK: - Generic types and extensions
/// A generic result type.
///
/// - success: Includes a value of a generic type as an associated value.
/// - failure: Includes an error as an associated value.
enum Result<Value> {
    case success(Value)
    case failure(Error)
    /// The result type represented as an optional where success wraps a value and failure is nil.
    var asOptional: Value? {
        switch self {
        case .success(let value): return value
        case .failure: return nil
        }
    }
}
// Via https://nshipster.com/void/
extension Result where Value == Void {
    /// When `Value` is `Void`, you can use `.success` instead of `.success(())`.
    static var success: Result { return .success(()) }
}

extension Sequence {
    /// Pass a sequence to a transforming function as a value.
    ///
    /// - Parameter transform: A function that takes the sequence as an input and returns a value.
    /// - Returns: The value produced by the transforming function.
    /// - Throws: Rethrows any error thrown by the transforming function.
    func pass<T>(_ transform: (Self) throws -> T) rethrows -> T {
        return try transform(self)
    }
}

// MARK: - Table view data sources
// Via https://www.swiftbysundell.com/posts/reusable-data-sources-in-swift?rq=table%20view%20data%20source
/// A generic table view data source for simple one-section tables. It must be configured with an
/// array of generic cell models, a cell reuse identifier, and a configurator function for binding
/// cells to cell models.
class PrefabTableViewDataSource<CellModel>: NSObject, UITableViewDataSource {
    
    typealias Config = (UITableViewCell, CellModel) -> UITableViewCell
    /// The models used to configure table view cells.
    let cellModels: [CellModel]
    /// The identifier used to deque a reusable cell of the correct type.
    private let reuseID: String
    /// The configurator used to configure a table view cell with a cell model.
    private let config: Config
    /// Create a table view data source from an array of cell models, a reuse identifier, and a
    /// configurator to configure the cells based on the models.
    ///
    /// - Parameters:
    ///   - cellModels: A generic model holding configuration information for the table view cells.
    ///   - reuseID: The reuse identifier.
    ///   - config: The configurator used to configure each cell with a model.
    init(_ cellModels: [CellModel], reuseID: String, config: @escaping Config) {
        self.cellModels = cellModels
        self.reuseID = reuseID
        self.config = config
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return config(tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath),
                      cellModels[indexPath.row])
    }
}

/// A multisection table view data source. Each section is controlled by the corresponding child
/// data source.
class MultisectionTableViewDataSource: NSObject, UITableViewDataSource {
    /// An array of table view data sources. Each data source controls one section of the resulting
    /// multisection table.
    var dataSources = [UITableViewDataSource]()
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSources.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSources[section].tableView(tableView, numberOfRowsInSection: 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return dataSources[indexPath.section].tableView(tableView,
                                                        cellForRowAt: IndexPath(row: indexPath.row,
                                                                                section: 0))
    }
}

// MARK: - View controllers

/// A view controller with a center-aligned activity indicator.
class ActivityIndicatorViewController: UIViewController {
    /// An enumeration representing valid sizes for the activity indicator.
    enum Size {
        /// A large activity indicator, suitable for a full-screen view controller.
        case large
        /// A small activity indicator, suitable for a small view controller.
        case small
    }
    
    private lazy var indicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        switch size {
        case .large: indicator = .init(style: .whiteLarge)
        case .small: indicator = .init(style: .white)
        }
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = color
        indicator.backgroundColor = backgroundColor
        indicator.isOpaque = true
        return indicator
    }()

    private var size = Size.large
    private var color = UIColor.gray
    private var backgroundColor = UIColor.white
    /// Creates a new view controller with a white background and a center-aligned gray
    /// activity indicator of the specified size.
    ///
    /// - Parameter size: The size of the activity indicator.
    convenience init(_ size: Size) {
        self.init()
        
        self.size = size
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = backgroundColor
        view.addSubview(indicator)
        NSLayoutConstraint
            .activate([view.centerXAnchor.constraint(equalTo: indicator.centerXAnchor),
                       view.centerYAnchor.constraint(equalTo: indicator.centerYAnchor)])
        
        indicator.startAnimating()
    }
}
