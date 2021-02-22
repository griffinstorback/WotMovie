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
    
    var category: GuessCategory {
        didSet {
            setNumberGuessed()
        }
    }
    
    private let categoryImageView: UIImageView
    private let categoryLabel: UILabel
    private let horizontalStack: UIStackView

    private var numberGuessedLabel: UILabel?
    private let verticalStack: UIStackView
    
    private let rightPointingArrowContainer: UIView
    private let rightPointingArrow: UIImageView
    private let outerHorizontalStack: UIStackView
    
    
    init(category: GuessCategory) {
        self.category = category
        
        categoryImageView = UIImageView(image: UIImage(named: category.imageName))
        categoryLabel = UILabel()
        horizontalStack = UIStackView()
        
        // if category is 'stats' (e.g. numberGuessed is set to nil), don't display numberGuessedLabel
        if category.numberGuessed != nil {
            numberGuessedLabel = UILabel()
        }
        
        verticalStack = UIStackView()
        
        rightPointingArrowContainer = UIView()
        rightPointingArrow = UIImageView()
        outerHorizontalStack = UIStackView()
        
        super.init(frame: .zero)
        
        setupViews()
        layoutViews()
        
        // need to explicitly call because the 'didSet' of 'category' is not called before super.init().
        setNumberGuessed()
    }
    
    private func setupViews() {
        backgroundColor = .white
        layer.cornerRadius = 20
        layer.masksToBounds = true
        giveShadow(radius: 10)
        
        categoryImageView.tintColor = Constants.Colors.defaultBlue
        categoryImageView.contentMode = .scaleAspectFit
        
        categoryLabel.text = category.title
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 18)
        categoryLabel.numberOfLines = 2
        
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 15
        
        verticalStack.axis = .vertical
        verticalStack.spacing = 10
        verticalStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        verticalStack.isLayoutMarginsRelativeArrangement = true
        
        let rightPointingArrowImage = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        rightPointingArrow.image = rightPointingArrowImage
        rightPointingArrow.tintColor = .tertiaryLabel
        rightPointingArrow.contentMode = .scaleAspectFit
    }
    
    private func layoutViews() {
        addSubview(outerHorizontalStack)
        outerHorizontalStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        outerHorizontalStack.addArrangedSubview(verticalStack)
        
        rightPointingArrowContainer.addSubview(rightPointingArrow)
        rightPointingArrow.anchor(top: nil, leading: rightPointingArrowContainer.leadingAnchor, bottom: nil, trailing: rightPointingArrowContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), size: CGSize(width: 20, height: 0))
        rightPointingArrow.anchorToCenter(yAnchor: rightPointingArrowContainer.centerYAnchor, xAnchor: nil)
        outerHorizontalStack.addArrangedSubview(rightPointingArrowContainer)
        
        verticalStack.addArrangedSubview(horizontalStack)
        horizontalStack.addArrangedSubview(categoryImageView)
        categoryImageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        categoryImageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
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
    
    func setNumberGuessed() {
        // if category has number to display (e.g. stats doesn't)
        if let numberGuessed = category.numberGuessed {
            
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
