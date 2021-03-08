//
//  DetailOverviewView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-19.
//

import Foundation
import UIKit

class DetailOverviewView: UIView {
        
    let posterImageView: PosterImageView
    
    private lazy var genreListView: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        return label
    }()
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(posterImageView)
        stackView.addArrangedSubview(genreListView)
        stackView.axis = .horizontal
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "?"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        return label
    }()
    private lazy var releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        return label
    }()
    private lazy var overviewTextView: UITextView = {
        let textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .systemBackground
        return textView
    }()
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(releaseDateLabel)
        stackView.addArrangedSubview(horizontalStackView)
        stackView.addArrangedSubview(overviewTextView)
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.backgroundColor = .systemBackground
        return stackView
    }()
    
    init(frame: CGRect, guessState: GuessDetailViewState) {
        posterImageView = PosterImageView(state: PosterImageViewState(guessDetailState: guessState))
        posterImageView.layer.cornerRadius = Constants.DetailOverviewPosterImage.size.height * Constants.imageCornerRadiusRatio
        posterImageView.layer.masksToBounds = true
        
        super.init(frame: frame)
        
        setupViews()
        layoutViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .systemBackground
    }
    
    private func layoutViews() {
        addSubview(verticalStackView)

        //posterImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: Constants.DetailOverviewPosterImage.size)
        
        posterImageView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.DetailOverviewPosterImage.size.width).isActive = true
        posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor, multiplier: 2/3).isActive = true
        verticalStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    public func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    public func setReleaseDate(dateString: String) {
        releaseDateLabel.text = dateString
    }
    
    // don't really need to do check with imagePath for this view, as it isn't being reused
    public func setPosterImage(_ image: UIImage?, _ imagePath: String?) {
        posterImageView.setImage(image)
    }
    
    public func setOverviewText(_ text: String) {
        overviewTextView.text = text
    }
    
    public func setGenreList(_ commaSeparatedList: String?) {
        genreListView.text = commaSeparatedList
    }
    
    public func setPosterImageState(_ state: PosterImageViewState, animated: Bool) {
        posterImageView.setState(state, animated: animated)
    }
}
