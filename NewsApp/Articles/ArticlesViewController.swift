//
//  ArticlesViewController.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import UIKit

class ArticlesViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var scrollUpButton: UIButton!
    
    let vm = ArticlesViewModel()
    let emptyView = EmptyStateView()
    private let footerSpinner = UIActivityIndicatorView(style: .medium)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "title"
        self.navigationItem.backButtonTitle = "Back"
        setupTableView()
        setupSearchBar()
        vm.delegate = self
        vm.fetchArticles()
    }
    
    private func setupTableView() {
        tableView.register(UINib(nibName: "ArticlesTableViewCell", bundle: nil), forCellReuseIdentifier: "ArticlesTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundView = nil
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.showsCancelButton = true
    }
    
    @IBAction func scrollUpButtonTapped(_ sender: Any) {
        let topIndex = IndexPath(row: 0, section: 0)
        tableView.scrollToRow(at: topIndex, at: .top, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y
        UIView.animate(withDuration: 0.25) {
            self.scrollUpButton.alpha = offset < 400 ? 0 : 1
        }
    }
}

extension ArticlesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.articles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ArticlesTableViewCell", for: indexPath) as? ArticlesTableViewCell else { return UITableViewCell() }
        let index = indexPath.row
        let article = vm.articles[index]
        cell.configCell(article: article, category: vm.getCategory)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let articleURL = vm.articles[index].url
        let vc = ArticlesWebViewViewController()
        vc.urlString = articleURL
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension ArticlesViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        guard let maxRow = indexPaths.map({ $0.row }).max() else { return }
        let threshold = max(vm.articles.count - 5, 0)
        
        if maxRow >= threshold {
            vm.fetchArticles()
        }
    }
}

extension ArticlesViewController { // Pagination Logics
    func showFooterLoading() {
        footerSpinner.startAnimating()
        footerSpinner.frame = CGRect(x: 0, y: 0, width: 0, height: 44)
        tableView.tableFooterView = footerSpinner
    }

    func hideFooterLoading() {
        footerSpinner.stopAnimating()
        tableView.tableFooterView = nil
    }
}

extension ArticlesViewController: ArticlesViewModelDelegate {
    func didStartLoading() {
        tableView.backgroundView = nil
        if vm.articles.isEmpty {
            showLoading()
        } else {
            showFooterLoading()
        }
    }
    
    func didFinishLoading() {
        hideLoading()
        hideFooterLoading()
    }
    
    func didUpdateArticles() {
        if vm.articles.isEmpty {
            tableView.backgroundView = emptyView
        } else {
            tableView.backgroundView = nil
        }
        tableView.reloadData()
    }
    
    func didReceiveError(_ message: String) {
        showDynamicToast(message: message, font: .systemFont(ofSize: 10))
    }
}

extension ArticlesViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        searchBar.resignFirstResponder()
        vm.searchArticles(keyword: text)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            vm.searchArticles(keyword: "")
        }
    }
}
