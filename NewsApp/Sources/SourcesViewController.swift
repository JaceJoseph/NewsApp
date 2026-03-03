//
//  SourcesViewController.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import UIKit

class SourcesViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    let vm = SourcesViewModel()
    let activityIndicator = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "News Sources"
        self.navigationItem.backButtonTitle = "Back"
        setupTable()
        setupSearchBar()
        setupVM()
    }
    
    private func setupTable() {
        tableView.register(UINib(nibName: "SourcesTableViewCell", bundle: nil), forCellReuseIdentifier: "SourcesTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.showsCancelButton = true
    }
    
    private func setupVM() {
        vm.delegate = self
        vm.fetchSources()
    }
}

extension SourcesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.filteredSources.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SourcesTableViewCell", for: indexPath) as? SourcesTableViewCell else { return UITableViewCell() }
        let index = indexPath.row
        let source = vm.filteredSources[index]
        cell.configCell(source: source)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // navigates to articles
    }
}

extension SourcesViewController: NewsSourcesViewModelDelegate {
    func didStartLoading() {
        showLoading()
    }
    
    func didFinishLoading() {
        hideLoading()
    }
    
    func didUpdateSources() {
        tableView.reloadData()
    }
    
    func didReceiveError(_ message: String) {
        showDynamicToast(message: message, font: .systemFont(ofSize: 10))
    }
}

extension SourcesViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        vm.searchSources(with: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        vm.searchSources(with: nil)
        searchBar.resignFirstResponder()
    }
}
