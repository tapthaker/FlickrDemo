import Foundation
import UIKit

class RecentSearchesTableViewDatasource: NSObject, UITableViewDataSource {

    private var queries = [Query]()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return queries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.dequeueCell(tableView: tableView, identifier: "Plain")
        cell.textLabel?.text = queries[indexPath.row].queryString
        return cell
    }

    func appendQueries(queries: [Query], to tableView: UITableView) {
        self.queries.append(contentsOf: queries)
        tableView.reloadData()
    }

    func query(at indexPath: IndexPath) -> Query {
        return queries[indexPath.row]
    }

    private func dequeueCell(tableView: UITableView, identifier: String) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: identifier) {
            return cell
        } else {
            return UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
    }
}
