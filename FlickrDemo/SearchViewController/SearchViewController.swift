import UIKit

class SearchViewController: UIViewController, UITableViewDelegate {

    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    let datasource = RecentSearchesTableViewDatasource()
    let table: Table<Query>

    required init?(coder aDecoder: NSCoder) {
        do {
            let context = try CoreManagedObjectContext(bundle: Bundle.main, mom: "QueryDataModel")
            table = Table<Query>(context: context)
        } catch {
            fatalError("Could not initialize Database")
        }
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupRecentSearches()
        setupSearchBar()
    }

    private func setupRecentSearches() {
        tableView.dataSource = datasource
        do {
            let queries = try table.query(withPredicate: nil)
            datasource.appendQueries(queries: queries, to: tableView)
        } catch {
            fatalError("Could not fetch recent Searches")
        }
        tableView.delegate = self
    }

    private func setupSearchBar() {
        searchBar.delegate = self
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let queryString = datasource.query(at: indexPath).queryString {
            showImagesFor(queryString)
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

    fileprivate func showImagesFor(_ query: String) {
        let viewController = ImagesViewController.forQuery(query)
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let queryString = searchBar.text else { return }
        let query = table.createEntity()
        query.queryString = queryString
        query.date = Date()
        try? table.save()
        showImagesFor(queryString)
    }
}
