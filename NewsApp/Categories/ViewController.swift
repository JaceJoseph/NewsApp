//
//  ViewController.swift
//  NewsApp
//
//  Created by Jesse on 03/03/26.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let vm = CategoryViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTable()
    }
    
    private func setupTable() {
        tableView.register(UINib(nibName: "CategoryTableCell", bundle: nil), forCellReuseIdentifier: "CategoryTableCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.newsCategory.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableCell", for: indexPath) as? CategoryTableCell else {return UITableViewCell()}
        let index = indexPath.row
        cell.configCell(category: vm.getCategory(index: index))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = indexPath.row
        let category = vm.getCategory(index: index)
        let vc = SourcesViewController()
        vc.vm.categoryID = category.id
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
