//
//  GuessCategoryView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-04.
//

import UIKit

protocol GuessCategoryViewDelegate: NSObjectProtocol {
    func categoryWasSelected(_ category: GuessCategory)
    func upgradeButtonPressed()
}

class GuessCategoryView: UIView {
    private weak var delegate: GuessCategoryViewDelegate?
    
    var category: GuessCategory {
        didSet {
            setNumberGuessed()
        }
    }
    
    override var bounds: CGRect {
        didSet {
            // update corner radius when bounds change.
            layer.cornerRadius = bounds.height * Constants.guessCategoryViewRadiusRatio
        }
    }
    
    // Image view width/height ratio, and Category text label size, depend on size of device
    static var categoryImageViewSizeRatio: CGFloat {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return 0.25
        case .pad:
            return 0.2
        default:
            return 0.25
        }
    }
    static var categoryLabelFont: UIFont {
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            return UIFont.systemFont(ofSize: 20, weight: .bold)
        case .pad:
            return UIFont.systemFont(ofSize: 22, weight: .bold)
        default:
            return UIFont.systemFont(ofSize: 20, weight: .bold)
        }
    }
    
    private let categoryImageView: UIImageView
    private let categoryLabel: UILabel
    private let horizontalStack: UIStackView

    private var numberGuessedLabel: UILabel?
    private let verticalStack: UIStackView
    
    private let rightEdgeImageViewContainer: UIView
    private let rightPointingArrow: UIImageView
    
    private var categoryIsLocked: Bool = false // set to true for .person type when user hasn't upgraded yet
    private let upgradeButton: ShrinkOnTouchButton // its a button, but functionality is same as pressing on view
    
    private let outerHorizontalStack: UIStackView
    
    
    init(category: GuessCategory, categoryIsLocked: Bool = false) {
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
        
        self.categoryIsLocked = categoryIsLocked
        upgradeButton = ShrinkOnTouchButton()
        
        outerHorizontalStack = UIStackView()
        
        super.init(frame: .zero)
        
        setupViews()
        layoutViews()
        
        // need to explicitly call because the 'didSet' of 'category' is not called before super.init().
        setNumberGuessed()
    }
    
    private func setupViews() {
        backgroundColor = UIColor.systemGray6//.withAlphaComponent(0.9)
        layer.masksToBounds = true
        
        categoryImageView.contentMode = .scaleAspectFit
        
        categoryLabel.text = category.shortTitle
        categoryLabel.font = GuessCategoryView.categoryLabelFont
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
        upgradeButton.setTitle("Unlock", for: .normal)
        upgradeButton.setTitleColor(.white, for: .normal)
        upgradeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        upgradeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        upgradeButton.layer.cornerRadius = 10
        upgradeButton.addTarget(self, action: #selector(upgradeButtonPressed), for: .touchUpInside)
    }
    
    @objc func upgradeButtonPressed() {
        delegate?.upgradeButtonPressed()
    }
    
    private func layoutViews() {
        addSubview(outerHorizontalStack)
        outerHorizontalStack.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        outerHorizontalStack.addArrangedSubview(verticalStack)
        
        // either show right pointing arrow to indicate category is selectable, or show an upgrade button instead, indicating user needs to upgrade.
        if categoryIsLocked {
            addUpgradeButtonRemoveChevron()
        } else {
            addChevronRemoveUpgradeButton()
        }
        
        verticalStack.addArrangedSubview(horizontalStack)
        horizontalStack.addArrangedSubview(categoryImageView)
        categoryImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: GuessCategoryView.categoryImageViewSizeRatio).isActive = true
        categoryImageView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: GuessCategoryView.categoryImageViewSizeRatio).isActive = true
        
        horizontalStack.addArrangedSubview(categoryLabel)
        
        if let numberGuessedLabel = numberGuessedLabel {
            verticalStack.addArrangedSubview(numberGuessedLabel)
        }
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
    
    func setCategoryIsLocked(to locked: Bool) {
        if locked {
            categoryIsLocked = true
            addUpgradeButtonRemoveChevron()
        } else {
            categoryIsLocked = false
            addChevronRemoveUpgradeButton()
        }
    }
    
    private func addUpgradeButtonRemoveChevron() {
        // remove right pointing chevron (if it exists)
        if subviews.contains(rightEdgeImageViewContainer) {
            outerHorizontalStack.removeArrangedSubview(rightEdgeImageViewContainer)
            rightPointingArrow.removeFromSuperview()
            rightEdgeImageViewContainer.removeFromSuperview()
        }
        
        guard !subviews.contains(upgradeButton) else { return }
        
        // add upgrade button as overlay (so that it doesnt cramp the text fields)
        addSubview(upgradeButton)
        upgradeButton.anchor(top: nil, leading: nil, bottom: nil, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10), size: CGSize(width: 90, height: 0))
        upgradeButton.anchorToCenter(yAnchor: centerYAnchor, xAnchor: nil)
    }
    
    private func addChevronRemoveUpgradeButton() {
        // remove upgrade button (if it exists)
        if subviews.contains(upgradeButton) {
            upgradeButton.removeFromSuperview()
        }
        
        // return if right pointing chevron already exists in horizontal stack view
        guard !outerHorizontalStack.arrangedSubviews.contains(rightEdgeImageViewContainer) else { return }
        
        outerHorizontalStack.addArrangedSubview(rightEdgeImageViewContainer)
        
        // add right pointing chevron
        rightEdgeImageViewContainer.addSubview(rightPointingArrow)
        rightPointingArrow.anchor(top: nil, leading: rightEdgeImageViewContainer.leadingAnchor, bottom: nil, trailing: rightEdgeImageViewContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5), size: CGSize(width: 20, height: 0))
        rightPointingArrow.anchorToCenter(yAnchor: rightEdgeImageViewContainer.centerYAnchor, xAnchor: nil)
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
            // if this category is .person and user hasn't upgraded, tapping category anywhere should display upgrade page
            if categoryIsLocked {
                delegate?.upgradeButtonPressed()
            } else {
                delegate?.categoryWasSelected(category)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setSelected(false)
    }
}
