//
//  DetailOverviewView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-19.
//

import Foundation
import UIKit

class DetailOverviewView: UIView {
    
    lazy var posterImageView: UIImageView = {
        return UIImageView()
    }()
    lazy var genreListView: UILabel = {
        return UILabel()
    }()
    lazy var horizontalStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.addArrangedSubview(posterImageView)
        stackView.addArrangedSubview(genreListView)
        stackView.axis = .horizontal
        return stackView
    }()
    
    lazy var overviewTextView: UITextView = {
        return UITextView()
    }()
    lazy var verticalStackView: UIStackView = {
        let stackView = UIStackView()
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
        addSubview(verticalStackView)
        setupLayout()
    }
    
    private func setupLayout() {
        verticalStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
    }
}
