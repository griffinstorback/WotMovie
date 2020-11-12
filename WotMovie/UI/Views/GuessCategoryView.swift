//
//  GuessCategoryView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-04.
//

import UIKit

protocol GuessCategoryViewDelegate {
    func categoryWasSelected(_ category: GuessCategory)
}

class GuessCategoryView: UIView {
    private var delegate: GuessCategoryViewDelegate?
    
    private let category: GuessCategory
    
    private let categoryImageView: UIImageView
    private let categoryLabel: UILabel
    private let horizontalStack: UIStackView

    private var numberGuessedLabel: UILabel?
    private let verticalStack: UIStackView
    
    init(category: GuessCategory) {
        self.category = category
        
        let categoryImage = UIImage(named: category.imageName)?.withRenderingMode(.alwaysTemplate)
        categoryImageView = UIImageView(image: categoryImage?.withTintColor(Constants.Colors.defaultBlue))
        categoryImageView.tintColor = Constants.Colors.defaultBlue
        categoryImageView.contentMode = .scaleAspectFit
        
        categoryLabel = UILabel()
        categoryLabel.text = category.title
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 16)
        
        horizontalStack = UIStackView()
        
        // if category is 'stats', don't display numberGuessedLabel
        if let numberGuessed = category.numberGuessed {
            numberGuessedLabel = UILabel()
            
            // if at least one has been guessed, make the number blue instead of black
            let numberTextAttributes: [NSAttributedString.Key : NSObject]
            if numberGuessed > 0 {
                numberTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18), NSAttributedString.Key.foregroundColor: Constants.Colors.defaultBlue]
            } else {
                numberTextAttributes = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)]
            }
            let numberText = NSMutableAttributedString(string: "\(numberGuessed)", attributes: numberTextAttributes)
            
            // keep the text after the number black, and not bold
            let numberGuessedTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)]
            let numberGuessedText = NSMutableAttributedString(string: " guessed correctly", attributes: numberGuessedTextAttributes)
            
            numberText.append(numberGuessedText)
            numberGuessedLabel?.attributedText = numberText
        }
        
        verticalStack = UIStackView()
        
        super.init(frame: .zero)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.masksToBounds = true
        giveShadow(radius: 10)
        
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 10
        
        verticalStack.axis = .vertical
        verticalStack.spacing = 10
        verticalStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        verticalStack.isLayoutMarginsRelativeArrangement = true
    }
    
    private func layoutViews() {
        addSubview(verticalStack)
        verticalStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        verticalStack.addArrangedSubview(horizontalStack)
        horizontalStack.addArrangedSubview(categoryImageView)
        categoryImageView.widthAnchor.constraint(equalToConstant: 60).isActive = true
        categoryImageView.heightAnchor.constraint(equalToConstant: 60).isActive = true
        horizontalStack.addArrangedSubview(categoryLabel)
        
        if let numberGuessedLabel = numberGuessedLabel {
            verticalStack.addArrangedSubview(numberGuessedLabel)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.updateShadow()
    }
    
    func setDelegate(_ delegate: GuessCategoryViewDelegate) {
        self.delegate = delegate
    }
    
    func setNumberGuessed(text: String) {
        numberGuessedLabel?.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        setSelected(true)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        setSelectedIfTouchWithinBoundsOfView(touches)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        unselectIfTouchWithinBoundsOfView(touches)
        
        if touchIsWithinBoundsOfView(touches) {
            delegate?.categoryWasSelected(category)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setSelected(false)
    }
}
