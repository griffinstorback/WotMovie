//
//  PersonOverviewView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-06.
//

import Foundation
import UIKit

class PersonOverviewView: UIView {
        
    private lazy var posterImageView: PosterImageView = {
        let posterImageView = PosterImageView(startHidden: true)
        posterImageView.layer.cornerRadius = Constants.PersonOverviewPosterImage.size.height * Constants.imageCornerRadiusRatio
        posterImageView.layer.masksToBounds = true
        return posterImageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "?"
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textAlignment = .center
        return label
    }()
    private lazy var overviewTextView: UITextView = {
        return UITextView()
    }()
    private lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(posterImageView)
        stackView.addArrangedSubview(nameLabel)
        stackView.addArrangedSubview(overviewTextView)
        stackView.axis = .vertical
        stackView.spacing = 5
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
        
        verticalStackView.backgroundColor = .white
        verticalStackView.alignment = .center
        
        addSubview(verticalStackView)
        setupLayout()
    }
    
    private func setupLayout() {
        posterImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: Constants.PersonOverviewPosterImage.size)
        verticalStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    public func setName(_ text: String) {
        nameLabel.text = text
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
