//
//  RedditCell.swift
//  SamplePhotosApp iOS
//
//  Created by Vladislav Murygin on 12/16/24.
//  Copyright © 2024 Apple. All rights reserved.
//

import UIKit

class RedditCell: UITableViewCell {

    static let identifier = "RedditCell"
    
    @IBOutlet weak var newsTitleLabel: UILabel!
    @IBOutlet weak var newsDateTitleLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        newsImage.backgroundColor = .systemGray5
        newsImage.layer.cornerRadius = 5
        newsImage.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Nib
    static func nib() -> UINib {
        return UINib(nibName: "RedditCell", bundle: nil)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        newsTitleLabel.text = nil
        newsDateTitleLabel.text = nil

        newsImage.image = UIImage(systemName: "photo.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        newsImage.backgroundColor = .systemGray5
        newsImage.contentMode = .scaleAspectFit
    }
    
    // MARK: - Configure Cell
    func configure(with article: RedditPost) {
        newsTitleLabel.text = article.title
        newsDateTitleLabel.text = article.createdDate.toRelativeString()
        setImage(from: article.thumbnail)
    }
    
    /// Set image
    private func setImage(from urlString: String?) {
        setupPlaceholderImage()

        guard let urlString = urlString,
              let url = URL(string: urlString),
              ["http", "https"].contains(url.scheme) else {
            return
        }

        if let cachedImage = ImageCache.shared.object(forKey: urlString as NSString) {
            updateImage(cachedImage)
            return
        }

        fetchImage(from: url, cacheKey: urlString)
    }

    /// Fetch image from url
    private func fetchImage(from url: URL, cacheKey: String) {
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self = self else { return }

            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                self.updatePlaceholderImage()
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                self.updatePlaceholderImage()
                return
            }

            ImageCache.shared.setObject(image, forKey: cacheKey as NSString)
            DispatchQueue.main.async {
                self.updateImage(image)
            }
        }.resume()
    }
    
    /// Update placeholder image
    private func updatePlaceholderImage() {
        DispatchQueue.main.async {
            self.setupPlaceholderImage()
        }
    }
    
    /// Set placeholder image
    private func setupPlaceholderImage() {
        let imageIcon = UIImage(systemName: "photo.fill")?.withTintColor(.white, renderingMode: .alwaysOriginal)
        newsImage.image = imageIcon
        newsImage.backgroundColor = .systemGray5
        newsImage.contentMode = .scaleAspectFit
    }
    
    /// Update image
    private func updateImage(_ image: UIImage) {
        newsImage.image = image
        newsImage.backgroundColor = .clear
        newsImage.contentMode = .scaleAspectFill
    }
    
}
