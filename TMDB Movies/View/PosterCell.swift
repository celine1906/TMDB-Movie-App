//
//  MovieCell.swift
//  TMDB Movies
//
//  Created by Regina Celine Adiwinata on 21/01/26.
//

import UIKit

class PosterCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .systemGray6
        iv.layer.cornerRadius = 8
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private let starImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "star.fill"))
        iv.tintColor = .systemYellow
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var ratingStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [starImageView, ratingLabel])
        stack.axis = .horizontal
        stack.spacing = 4
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(ratingStackView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: ratingStackView.topAnchor, constant: -4),
            
            ratingStackView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 6),
            ratingStackView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ratingStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            starImageView.widthAnchor.constraint(equalToConstant: 14),
            starImageView.heightAnchor.constraint(equalToConstant: 14)
        ])
    }

    func configure(with item: PosterPresentable) {
        ratingLabel.text = item.ratingText
        imageView.image = nil

        if let url = item.tmdbPosterURL {
            ImageCache.shared.loadImage(from: url) { [weak self] image in
                self?.imageView.image = image
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        ratingLabel.text = nil
    }
}
