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
    let typeString: String // should be either MOVIE or TV SHOW, as type .person doesn't use this view
    
    // contains meta info (such as entity type, genres, etc.), displayed on right of poster image.
    private lazy var metaInfoVerticalStackView: UIStackView = {
        let stackView = UIStackView()
        
        /*let tempTypeLabel = UILabel()
        tempTypeLabel.text = typeString
        tempTypeLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        tempTypeLabel.textColor = .secondaryLabel*/
        stackView.addArrangedSubview(typeLabel)
        stackView.addArrangedSubview(genreListView)
        stackView.addArrangedSubview(ratingButtonContainerView)
        
        stackView.axis = .vertical
        stackView.spacing = 5
        return stackView
    }()
    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.text = typeString
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()
    private lazy var genreListView: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private lazy var ratingButton: RatingButton = {
        // A button because it will link to the TMDB page - also don't show when hidden.
        let button = RatingButton()
        button.backgroundColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 6
        
        return button
    }()
    private lazy var ratingButtonContainerView: UIView = {
        let buttonContainer = UIView()
        
        buttonContainer.addSubview(ratingButton)
        ratingButton.anchor(top: buttonContainer.topAnchor, leading: buttonContainer.leadingAnchor, bottom: buttonContainer.bottomAnchor, trailing: nil)
        
        // initialize hidden - unhide when a rating is set.
        buttonContainer.isHidden = true
        
        return buttonContainer
    }()
    
    
    
    private lazy var posterImageAndMetaInfoHorizontalStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.addArrangedSubview(posterImageView)
        stackView.addArrangedSubview(metaInfoVerticalStackView)
        
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    
    private lazy var releaseDateAndContentLengthStackView: UIStackView = {
        let stackView = UIStackView()
        
        stackView.addArrangedSubview(releaseDateLabel)
        stackView.addArrangedSubview(UIView())
        stackView.addArrangedSubview(contentLengthLabel)
        
        stackView.axis = .horizontal
        stackView.spacing = 5
        return stackView
    }()
    private lazy var releaseDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    // contains either movie length in minutes, or tv show length in episodes (and seasons)
    private lazy var contentLengthLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.adjustsFontSizeToFitWidth = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "?"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
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
        stackView.addArrangedSubview(releaseDateAndContentLengthStackView)
        stackView.addArrangedSubview(posterImageAndMetaInfoHorizontalStackView)
        stackView.addArrangedSubview(overviewTextView)
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.backgroundColor = .systemBackground
        return stackView
    }()
    
    init(frame: CGRect, guessState: GuessDetailViewState, typeString: String) {
        posterImageView = PosterImageView(state: PosterImageViewState(guessDetailState: guessState))
        posterImageView.layer.cornerRadius = Constants.DetailOverviewPosterImage.size.height * Constants.imageCornerRadiusRatio
        posterImageView.layer.masksToBounds = true
        
        self.typeString = typeString
        
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
        
        //posterImageView.heightAnchor.constraint(lessThanOrEqualToConstant: Constants.DetailOverviewPosterImage.size.height).isActive = true
        //posterImageView.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.DetailOverviewPosterImage.size.width).isActive = true
        posterImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: Constants.DetailOverviewPosterImage.size)
        posterImageView.widthAnchor.constraint(equalTo: posterImageView.heightAnchor, multiplier: 2/3).isActive = true
        verticalStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    public func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    public func setReleaseDate(dateString: String) {
        releaseDateLabel.text = dateString
    }
    
    public func setContentLength(contentLengthString: String) {
        contentLengthLabel.text = contentLengthString
    }
    
    public func addRating(rating: Double?) {
        if let rating = rating {
            //ratingButton.setTitle(String(format: "%.1f on TMDb", rating), for: .normal)
            ratingButton.setRating(rating: rating)
            ratingButtonContainerView.isHidden = false
        } else {
            // if nil was passed, don't show a rating at all.
            removeRating()
        }
    }
    
    public func removeRating() {
        ratingButtonContainerView.isHidden = true
    }
    
    // don't need to deal with image loading states here - they're handled in PosterImageView
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
