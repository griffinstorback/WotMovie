//
//  GuessCategoryView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-11-04.
//

import UIKit

protocol GuessCategoryViewDelegate {
    func categoryWasSelected(_ type: CategoryType)
}

class GuessCategoryView: UIView {
    private var delegate: GuessCategoryViewDelegate?
    
    private let type: CategoryType
    
    private let categoryImageView: UIImageView
    private let categoryLabel: UILabel
    private let horizontalStack: UIStackView

    private var numberGuessedLabel: UILabel?
    private let verticalStack: UIStackView
    
    init(category: GuessCategory) {
        type = category.type
        
        categoryImageView = UIImageView(image: UIImage(systemName: category.imageName))//UIImage(named: category.imageName))
        categoryLabel = UILabel()
        categoryLabel.text = category.title
        categoryLabel.font = UIFont.boldSystemFont(ofSize: 16)
        horizontalStack = UIStackView()
        
        // if category is 'stats', don't display numberGuessedLabel
        if let numberGuessedText = category.subtitle {
            numberGuessedLabel = UILabel()
            numberGuessedLabel?.text = numberGuessedText
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
        
        if touchIsWithinBoundsOfView(touches) {
            setSelected(true)
        } else {
            setSelected(false)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        // if touch ended outside this view, ignore.
        guard touchIsWithinBoundsOfView(touches) else {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.setSelected(false)
        }
        delegate?.categoryWasSelected(type)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        setSelected(false)
    }
    
    private func touchIsWithinBoundsOfView(_ touches: Set<UITouch>) -> Bool {
        if let touchPoint = touches.first?.location(in: self) {
            if self.bounds.contains(touchPoint) {
                return true
            }
        }
        
        return false
    }
    
    private func setSelected(_ selected: Bool) {
        if selected {
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform.identity.scaledBy(x: 0.95, y: 0.95)
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.transform = CGAffineTransform.identity.scaledBy(x: 1, y: 1)
            }
        }
    }
}
