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
        
        likeButton.accessibilityIdentifier = "LikeButton"
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

    private func likeButtonImage(_ isLiked: Bool) -> UIImage {
        isLiked ? UIImage.likeButtonOn : UIImage.likeButtonOff
    }

    // MARK: - Public Methods
    func setImage(_ image: UIImage) {
        cellImage.image = image
    }

    func setText(_ text: String) {
        dateLabel.text = text
    }

    func setIsLiked(_ isLiked: Bool) {
        likeButton.setImage(likeButtonImage(isLiked), for: .normal)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
        
        // Сброс градиента
        gradientLayer.removeFromSuperlayer()
        setupGradient()
    }

    @IBAction func likeButtonClicked(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
    }
}
