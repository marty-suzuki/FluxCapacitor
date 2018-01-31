//
//  UserViewCell.swift
//  GithubKitForSample
//
//  Created by marty-suzuki on 2017/08/05.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import Nuke

public final class UserViewCell: UITableViewCell, Nibable {
    public typealias RegisterType = RegisterNib
    
    private static let shared = UserViewCell.makeFromNib()
    private static let minimumHeight: CGFloat = 88

    @IBOutlet weak var thumbnailImageView: UIImageView! {
        didSet {
            thumbnailImageView.layer.cornerRadius = 4
            thumbnailImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var repositoryLabel: UILabel! {
        didSet {
            repositoryLabel.setText(as: .repo, ofSize: 16)
        }
    }
    @IBOutlet weak var repositoryCountLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel! {
        didSet {
            followingLabel.setText(as: .eye, ofSize: 16)
        }
    }
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerLabel: UILabel! {
        didSet {
            followerLabel.setText(as: .organization, ofSize: 16)
        }
    }
    @IBOutlet weak var followerCountLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    
    public static func calculateHeight(with user: User, and tableView: UITableView) -> CGFloat {
        shared.configure(with: user)
        shared.frame.size.width = tableView.bounds.size.width
        shared.layoutIfNeeded()
        shared.bioLabel.preferredMaxLayoutWidth = shared.bioLabel.bounds.size.width
        let height = shared.systemLayoutSizeFitting(UILayoutFittingCompressedSize).height
        return max(minimumHeight, height)
    }
    
    let bioLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        return label
    }()
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    private(set) lazy var locationContentView: UIView = {
        let locationContentView = UIView()
        let iconLabel = UILabel()
        iconLabel.setText(as: .location, ofSize: 14)
        iconLabel.translatesAutoresizingMaskIntoConstraints = false
        locationContentView.addSubview(iconLabel)
        NSLayoutConstraint.activate([
            iconLabel.topAnchor.constraint(equalTo: locationContentView.topAnchor),
            iconLabel.leadingAnchor.constraint(equalTo: locationContentView.leadingAnchor),
            iconLabel.bottomAnchor.constraint(equalTo: locationContentView.bottomAnchor),
            iconLabel.widthAnchor.constraint(equalToConstant: 14)
        ])
        let locationLabel = self.locationLabel
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        locationContentView.addSubview(locationLabel)
        locationContentView.trailingAnchor.constraint(greaterThanOrEqualTo: locationContentView.trailingAnchor, constant: 0)
        NSLayoutConstraint.activate([
            locationLabel.topAnchor.constraint(equalTo: locationContentView.topAnchor),
            locationLabel.trailingAnchor.constraint(greaterThanOrEqualTo: locationContentView.trailingAnchor, constant: 0),
            locationLabel.bottomAnchor.constraint(equalTo: locationContentView.bottomAnchor),
            locationLabel.leadingAnchor.constraint(equalTo: iconLabel.trailingAnchor, constant: 4)
        ])
        return locationContentView
    }()
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        Manager.shared.cancelRequest(for: thumbnailImageView)
        thumbnailImageView.image = nil
    }
    
    public func configure(with user: User) {
        Manager.shared.loadImage(with: user.avatarURL, into: thumbnailImageView)
        userNameLabel.text = user.login
        repositoryCountLabel.text = user.repositoryCount.truncateString
        followingCountLabel.text = user.followingCount.truncateString
        followerCountLabel.text = user.followerCount.truncateString

        if user.location?.isEmpty ?? true {
            if stackView.arrangedSubviews.contains(locationContentView) {
                stackView.removeArrangedSubview(locationContentView)
            }
            locationContentView.removeFromSuperview()
        } else if !stackView.arrangedSubviews.contains(locationContentView) {
            stackView.insertArrangedSubview(locationContentView, at: 0)
        }
        locationLabel.text = user.location
        
        if user.bio?.isEmpty ?? true {
            if stackView.arrangedSubviews.contains(bioLabel) {
                stackView.removeArrangedSubview(bioLabel)
            }
            bioLabel.removeFromSuperview()
        } else if !stackView.arrangedSubviews.contains(bioLabel) {
            stackView.insertArrangedSubview(bioLabel, at: 0)
        }
        bioLabel.text = user.bio
    }
}
