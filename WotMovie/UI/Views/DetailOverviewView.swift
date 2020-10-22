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
        return PosterImageView()
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
        label.font = UIFont.systemFont(ofSize: 32)
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
        backgroundColor = .lightGray
        overviewTextView.isScrollEnabled = false
        overviewTextView.backgroundColor = .lightGray
        overviewTextView.font = UIFont.systemFont(ofSize: 17.0)
        
        genreListView.text = "Horror, Comedy, Anything"

        verticalStackView.backgroundColor = .lightGray
        
        addSubview(verticalStackView)
        setupLayout()
    }
    
    private func setupLayout() {
        posterImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 133, height: 200))
        verticalStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
    
    func setTitle(text: String) {
        titleLabel.text = text
    }
    
    func setPosterImage(image: UIImage?) {
        posterImageView.image = image
    }
    
    func setOverviewText(text: String) {
        overviewTextView.text = text
    }
    
    func removePosterImageBlurEffectOverlay(animated: Bool) {
        posterImageView.removeBlurEffectOverlay(animated: animated)
    }
    
    func addPosterImageBlurEffectOverlay(animated: Bool) {
        posterImageView.addBlurEffectOverlay(animated: animated)
    }
}
