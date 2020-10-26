//
//  DetailOverviewView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-19.
//

import Foundation
import UIKit

class DetailOverviewView: UIView {
    
    private lazy var posterImageView: PosterImageView = {
        return PosterImageView(startHidden: true)
    }()
    private lazy var genreListView: UILabel = {
        return UILabel()
    }()
    private lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(posterImageView)
        stackView.addArrangedSubview(genreListView)
        stackView.axis = .horizontal
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "?"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        return label
    }()
    private lazy var overviewTextView: UITextView = {
        return UITextView()
    }()
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(horizontalStackView)
        stackView.addArrangedSubview(overviewTextView)
        stackView.axis = .vertical
        return stackView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        backgroundColor = .white
        overviewTextView.isScrollEnabled = false
        overviewTextView.isUserInteractionEnabled = false
        overviewTextView.isEditable = false
        overviewTextView.backgroundColor = .white
        overviewTextView.font = UIFont.systemFont(ofSize: 17.0)
        
        genreListView.text = "Horror, Comedy, Anything"

        verticalStackView.backgroundColor = .white
        
        addSubview(verticalStackView)
        setupLayout()
    }
    
    private func setupLayout() {
        posterImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 140, height: 210))
        verticalStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    public func setTitle(_ text: String) {
        titleLabel.text = text
    }
    
    public func setPosterImage(_ image: UIImage?) {
        posterImageView.image = image
    }
    
    public func setOverviewText(_ text: String) {
        overviewTextView.text = text
    }
    
    public func removePosterImageBlurEffectOverlay(animated: Bool) {
        posterImageView.removeBlurEffectOverlay(animated: animated)
    }
    
    public func addPosterImageBlurEffectOverlay(animated: Bool) {
        posterImageView.addBlurEffectOverlay(animated: animated)
    }
}
