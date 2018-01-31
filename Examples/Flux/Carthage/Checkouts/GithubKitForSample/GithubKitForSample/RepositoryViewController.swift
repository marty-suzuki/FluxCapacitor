//
//  RepositoryViewController.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/08/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import GithubKit
import SafariServices

final class RepositoryViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    fileprivate private(set) var repositories: [Repository] = [] {
        didSet {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    private let user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: String(describing: RepositoryViewController.self), bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(RepositoryViewCell.self)
        tableView.dataSource = self
        tableView.delegate = self
        
        let request = UserNodeRequest(id: user.id, after: nil)
        _ = ApiSession.shared.send(request) { [weak self] in
            switch $0 {
            case .success(let value):
                self?.repositories = value.nodes
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension RepositoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(RepositoryViewCell.self, for: indexPath)
        cell.configure(with: repositories[indexPath.row])
        return cell
    }
}

extension RepositoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return RepositoryViewCell.calculateHeight(with: repositories[indexPath.row], and: tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let vc = SFSafariViewController(url: repositories[indexPath.row].url)
        navigationController?.pushViewController(vc, animated: true)
    }
}
