//
//  RepositoryViewCell.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/08/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit

public final class RepositoryViewCell: UITableViewCell, Nibable {
    public typealias RegisterType = RegisterNib
    
    private static let shared = RepositoryViewCell.makeFromNib()
    private static let minimumHeight: CGFloat = 88
    
    @IBOutlet weak var repositoryNameLabel: UILabel!
    
    
    @IBOutlet weak var languageContentView: UIView!
    @IBOutlet weak var languageColorView: UIView! {
        didSet {
            let size = languageColorView.bounds.size.width
            languageColorView.layer.cornerRadius = size / 4
            languageColorView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var starLabel: UILabel! {
        didSet {
            starLabel.setText(as: .star, ofSize: 14)
        }
    }
    @IBOutlet weak var starCountLabel: UILabel!
    @IBOutlet weak var forkLabel: UILabel! {
        didSet {
            forkLabel.setText(as: .repoFork, ofSize: 14)
        }
    }
    @IBOutlet weak var forkCountLabel: UILabel!
    
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    @IBOutlet weak var updatedAtLabel: UILabel!
    
    @IBOutlet weak var stackView: UIStackView!
    
    public static func calculateHeight(with repository: Repository, and tableView: UITableView) -> CGFloat {
        shared.configure(with: repository)
        shared.frame.size.width = tableView.bounds.size.width
        shared.layoutIfNeeded()
        shared.repositoryNameLabel.preferredMaxLayoutWidth = shared.repositoryNameLabel.bounds.size.width
        shared.descriptionLabel.preferredMaxLayoutWidth = shared.descriptionLabel.bounds.size.width
        let height = shared.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        return max(minimumHeight, height)
    }
    
    public func configure(with repository: Repository) {
        repositoryNameLabel.text = repository.name
        
        languageContentView.isHidden = repository.language == nil
        languageLabel.text = repository.language?.name
        if let color = repository.language?.color {
            languageColorView.backgroundColor = UIColor(hexString: color)
        } else {
            languageColorView.backgroundColor = nil
        }
        starCountLabel.text = repository.stargazerCount.truncateString
        forkCountLabel.text = repository.forkCount.truncateString
        
        if repository.introduction?.isEmpty ?? true {
            if stackView.arrangedSubviews.contains(descriptionLabel) {
                stackView.removeArrangedSubview(descriptionLabel)
            }
            descriptionLabel.removeFromSuperview()
        } else if !stackView.arrangedSubviews.contains(descriptionLabel) {
            stackView.insertArrangedSubview(descriptionLabel, at: 0)
        }
        descriptionLabel.text = repository.introduction
        
        let updatedAt = DateFormatter.default.string(from: repository.updatedAt)
        updatedAtLabel.text = "Updated on \(updatedAt)"
    }
}
