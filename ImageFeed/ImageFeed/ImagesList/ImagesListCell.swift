//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Kirill on 25.07.2024.
//

import UIKit
import Kingfisher

    // MARK: - Protocol

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    // MARK: - Properties
    
    static let reuseIdentifier = "ImagesListCell"
    private let gradientLayer = CAGradientLayer()
    weak var delegate: ImagesListCellDelegate?

    
    // MARK: - Outlets
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Устанавливаем высоту градиентного слоя так, чтобы он покрывал всю область до верхнего края текста даты
        let dateLabelFrame = cellImage.convert(dateLabel.frame, from: dateLabel.superview)
        let gradientHeight = cellImage.bounds.height - dateLabelFrame.minY
        gradientLayer.frame = CGRect(x: 0, y: dateLabelFrame.minY, width: cellImage.bounds.width, height: gradientHeight)
    }
    
    // MARK: - Private Methods
    
    private func setupGradient() {
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.7).cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        cellImage.layer.addSublayer(gradientLayer)
    }
    
    // MARK: - Public Methods
    
    func configure(image: UIImage, text: String, isLiked: Bool) {
            let LikeButtonImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")

            cellImage.image = image
            dateLabel.text = text
            likeButton.setImage(LikeButtonImage, for: .normal)
        }
        
        func setIsLiked(_ isLiked: Bool) {
            let LikeButtonImage = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")

            self.likeButton.setImage(LikeButtonImage, for: .normal)
            }
        
        override func prepareForReuse() {
            super.prepareForReuse()
            cellImage.kf.cancelDownloadTask()
            cellImage.image = nil
            dateLabel.text = nil
        }
        @IBAction func likeButtonClicked(_ sender: Any) {
            delegate?.imageListCellDidTapLike(self)
        }
}
