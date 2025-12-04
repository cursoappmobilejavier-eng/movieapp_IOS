//
//  MovieViewCell.swift
//  MovieApp-iOS
//
//  Created by Mananas on 3/12/25.
//

import UIKit

class MovieViewCell: UITableViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.cancelImageLoad()
        posterImageView.image = nil
        titleLabel.text = nil
        //yearLabel.text = nil
    }

    func render(with movie: MovieSearchItem) {
        titleLabel.text = movie.title
        //yearLabel.text = movie.year
        posterImageView.loadFrom(url: movie.poster)
    }
}
