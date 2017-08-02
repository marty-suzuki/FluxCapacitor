//
//  RepositoryViewCell.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import GithubApiSession

final class RepositoryViewCell: UITableViewCell, Nibable {
    static let defaultHeight: CGFloat = 76
    
    @IBOutlet weak var repositoryNameLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var forkCountLabel: UILabel!

    func configure(with repository: Repository) {
        repositoryNameLabel.text = repository.name
        languageLabel.text = repository.language
        starCountLabel.text = "\(repository.stargazerCount)"
        forkCountLabel.text = "\(repository.forkCount)"
    }
}
