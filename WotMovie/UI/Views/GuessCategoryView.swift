//
//  GuessCategoryView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-04.
//

import UIKit

protocol GuessCategoryViewDelegate: NSObjectProtocol {
    func categoryWasSelected(_ category: GuessCategory)
}

class GuessCategoryView: UIView {
    private weak var delegate: GuessCategoryViewDelegate?
    
    var category: GuessCategory {
        didSet {
            setNumberGuessed()
        }
    }
    
    static var categoryImageViewSize: CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    private let categoryImageView: UIImageView
    private let categoryLabel: UILabel
    private let horizontalStack: UIStackView

    private var numberGuessedLabel: UILabel?
    private let verticalStack: UIStackView
    
    private let rightEdgeImageViewContainer: UIView
    private let rightPointingArrow: UIImageView
    private let upgradeButton: ShrinkOnTouchButton // its a button, but we don't need button functionality (this whole view is like a big button already)
    
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
        
        rightEdgeImageViewContainer = UIView()
        rightPointingArrow = UIImageView()
        upgradeButton = ShrinkOnTouchButton()
        
        outerHorizontalStack = UIStackView()
        
        super.init(frame: .zero)
        
        setupViews()
        layoutViews()
        
        // need to explicitly call because the 'didSet' of 'category' is not called before super.init().
        setNumberGuessed()
    }
    
    private func setupViews() {
        backgroundColor = UIColor.systemGray5.withAlphaComponent(0.75)
        layer.cornerRadius = 20
        layer.masksToBounds = true
        
        //categoryImageView.tintColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        categoryImageView.contentMode = .scaleAspectFit
        
        //categoryLabel.text = category.title
        categoryLabel.text = category.shortTitle
        categoryLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        categoryLabel.numberOfLines = 2
        
        horizontalStack.axis = .horizontal
        horizontalStack.spacing = 20
        
        verticalStack.axis = .vertical
        verticalStack.spacing = 10
        verticalStack.layoutMargins = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        verticalStack.isLayoutMarginsRelativeArrangement = true
        
        let rightPointingArrowImage = UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .bold))
        rightPointingArrow.image = rightPointingArrowImage
        rightPointingArrow.tintColor = .tertiaryLabel
        rightPointingArrow.contentMode = .scaleAspectFit
        
        upgradeButton.backgroundColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        upgradeButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        upgradeButton.setTitle("Upgrade", for: .normal)
        upgradeButton.setTitleColor(.white, for: .normal)
        upgradeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        upgradeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        upgradeButton.layer.cornerRadius = 10
        upgradeButton.addTarget(self, action: #selector(upgradeButtonPressed), for: .touchUpInside)
    }
    
    @objc func upgradeButtonPressed() {
        print("** UPGRADE BUTTON PRESSED")
        delegate?.categoryWasSelected(category)
    }
    
    private func layoutViews() {
        addSubview(outerHorizontalStack)
        outerHorizontalStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        outerHorizontalStack.addArrangedSubview(verticalStack)
        
        // either show right pointing arrow to indicate category is selectable, or show a "Pro" button instead, indicating user needs to upgrade.
        if category.type != .person {
            rightEdgeImageViewContainer.addSubview(rightPointingArrow)
            rightPointingArrow.anchor(top: nil, leading: rightEdgeImageViewContainer.leadingAnchor, bottom: nil, trailing: rightEdgeImageViewContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), size: CGSize(width: 20, height: 0))
            rightPointingArrow.anchorToCenter(yAnchor: rightEdgeImageViewContainer.centerYAnchor, xAnchor: nil)
        } else {
            rightEdgeImageViewContainer.addSubview(upgradeButton)
            upgradeButton.anchor(top: nil, leading: rightEdgeImageViewContainer.leadingAnchor, bottom: nil, trailing: rightEdgeImageViewContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10), size: CGSize(width: 90, height: 0))
            //upgradeButton.anchor(top: nil, leading: rightEdgeImageViewContainer.leadingAnchor, bottom: nil, trailing: rightEdgeImageViewContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10))
            upgradeButton.anchorToCenter(yAnchor: rightEdgeImageViewContainer.centerYAnchor, xAnchor: nil)
        }
        outerHorizontalStack.addArrangedSubview(rightEdgeImageViewContainer)
        
        verticalStack.addArrangedSubview(horizontalStack)
        horizontalStack.addArrangedSubview(categoryImageView)
        categoryImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: GuessCategoryView.categoryImageViewSize)
        horizontalStack.addArrangedSubview(categoryLabel)
        
        if let numberGuessedLabel = numberGuessedLabel {
            verticalStack.addArrangedSubview(numberGuessedLabel)
        }
        
        
        // ALTERNATE ATTEMPT BELOW (using no stack views)
        
        /*addSubview(rightEdgeImageViewContainer)
        rightEdgeImageViewContainer.anchor(top: topAnchor, leading: nil, bottom: bottomAnchor, trailing: trailingAnchor)
        
        rightEdgeImageViewContainer.addSubview(rightPointingArrow)
        rightPointingArrow.anchor(top: nil, leading: rightEdgeImageViewContainer.leadingAnchor, bottom: nil, trailing: rightEdgeImageViewContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), size: CGSize(width: 20, height: 0))
        rightPointingArrow.anchorToCenter(yAnchor: rightEdgeImageViewContainer.centerYAnchor, xAnchor: nil)
        
        let numberGuessedLabelContainer = UIView()
        addSubview(numberGuessedLabelContainer)
        if let numberGuessedLabel = numberGuessedLabel {
            numberGuessedLabelContainer.addSubview(numberGuessedLabel)
            numberGuessedLabel.anchor(top: numberGuessedLabelContainer.topAnchor, leading: numberGuessedLabelContainer.leadingAnchor, bottom: numberGuessedLabelContainer.bottomAnchor, trailing: numberGuessedLabelContainer.trailingAnchor)
        }
        numberGuessedLabelContainer.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: rightEdgeImageViewContainer.leadingAnchor)
        
        addSubview(categoryImageView)
        categoryImageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: numberGuessedLabelContainer.topAnchor, trailing: nil)
        
        let categoryLabelContainer = UIView()
        addSubview(categoryLabelContainer)
        categoryLabelContainer.anchor(top: topAnchor, leading: categoryImageView.trailingAnchor, bottom: numberGuessedLabelContainer.topAnchor, trailing: rightEdgeImageViewContainer.leadingAnchor)
        
        categoryLabelContainer.addSubview(categoryLabel)
        categoryLabel.anchor(top: nil, leading: categoryLabelContainer.leadingAnchor, bottom: nil, trailing: categoryLabelContainer.trailingAnchor)
        categoryLabel.anchorToCenter(yAnchor: categoryLabelContainer.centerYAnchor, xAnchor: nil)*/
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
                numberTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold), NSAttributedString.Key.foregroundColor: UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue]
            } else {
                numberTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .bold)]
            }
            let numberText = NSMutableAttributedString(string: "\(numberGuessed)", attributes: numberTextAttributes)
            
            // keep the text after the number black, and not bold
            let numberGuessedTextAttributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17, weight: .medium)]
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
