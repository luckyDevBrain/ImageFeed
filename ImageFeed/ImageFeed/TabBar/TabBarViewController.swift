//
//  TabBarViewController.swift
//  ImageFeed
//
//  Created by Kirill on 15.09.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        configureSubviews()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(withIdentifier:"ImagesListViewController")
        let profileViewController = ProfileViewController()
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage.tabProfileActive,
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
    
    private func configureSubviews() {
        tabBar.barTintColor = UIColor.ypBlack
        tabBar.tintColor = UIColor.ypWhite
    }
}
