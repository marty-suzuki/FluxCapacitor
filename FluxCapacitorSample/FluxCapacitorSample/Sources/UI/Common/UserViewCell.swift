//
//  SearchViewCell.swift
//  FluxCapacitorSample
//
//  Created by marty-suzuki on 2017/08/02.
//  Copyright © 2017年 marty-suzuki. All rights reserved.
//

import UIKit
import GithubApiSession
import Nuke

final class UserViewCell: UITableViewCell, Nibable {
    static let defaultHeight : CGFloat = 88
    
    @IBOutlet weak var thumbnailImageView: UIImageView! {
        didSet {
            thumbnailImageView.layer.cornerRadius = 4
            thumbnailImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var repositoryCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        Manager.shared.cancelRequest(for: thumbnailImageView)
        thumbnailImageView.image = nil
    }
    
    func configure(with user: User) {
        Manager.shared.loadImage(with: user.avatarURL, into: thumbnailImageView)
        usernameLabel.text = user.login
        repositoryCountLabel.text = "\(user.repositoryCount)"
        followingCountLabel.text = "\(user.followingCount)"
        followerCountLabel.text = "\(user.followerCount)"
    }
}
