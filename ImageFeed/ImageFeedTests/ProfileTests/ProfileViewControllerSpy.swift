//
//  ProfileViewControllerSpy.swift
//  ImageFeed
//
//  Created by Kirill on 29.09.2024.
//

import ImageFeed
import UIKit

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var presenter: ProfilePresenterProtocol?
    var didCallAddExitButton: Bool = false
    
    func addProfilePic() {}
    
    func addExitButton() {}
    
    func addNameLabel() {}
    
    func addLoginLabel() {}
    
    func addDescriptionLabel() {}
    
    func updateAvatar() {}
    
    func showAlert(alert: UIAlertController) {}
    
    
}
