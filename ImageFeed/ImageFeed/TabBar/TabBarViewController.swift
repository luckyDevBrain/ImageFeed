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
        if let view = imagesListViewController as? ImagesListViewController {
            view.presenter = ImagesListPresenter(view: view as? ImagesListInput)
        }
        
        let profileViewController = ProfileViewController()
        profileViewController.presenter = ProfileViewPresenter(view: profileViewController)
        
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
