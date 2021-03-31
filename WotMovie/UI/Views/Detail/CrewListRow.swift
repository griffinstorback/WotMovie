//
//  CrewListRow.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-03-30.
//

import UIKit

protocol CrewListRowDelegate: NSObjectProtocol {
    func present(index: Int, section: CrewTypeSection, fromCard: UIView)
}

class CrewListRow: UIView {
    
    weak var delegate: CrewListRowDelegate?
    
    // image height dictates height of view, so imageHeight + (2 * imageTopAndBottomPadding) is the height of the cell.
    static let imageHeight: CGFloat = 80
    static let imageTopAndBottomPadding: CGFloat = 5
    
    let id: Int
    let section: CrewTypeSection
    
    let imageView: UIImageView
    let nameLabel: UILabel
    
    init(frame: CGRect, id: Int, section: CrewTypeSection) {
        self.id = id
        self.section = section
        
        imageView = UIImageView()
        nameLabel = UILabel()
        
        super.init(frame: frame)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = CrewListRow.imageHeight * Constants.imageCornerRadiusRatio
        imageView.layer.masksToBounds = true
        imageView.backgroundColor = .systemGray4
    }
    
    private func layoutViews() {
        addSubview(imageView)
        imageView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: nil, padding: UIEdgeInsets(top: CrewListRow.imageTopAndBottomPadding, left: 10, bottom: CrewListRow.imageTopAndBottomPadding, right: 0), size: CGSize(width: 0, height: CrewListRow.imageHeight))
        imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 2/3).isActive = true
        
        addSubview(nameLabel)
        nameLabel.anchor(top: topAnchor, leading: imageView.trailingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setDelegate(_ delegate: CrewListRowDelegate) {
        self.delegate = delegate
    }
    
    public func setNameLabel(text: String) {
        nameLabel.text = text
    }
    
    public func setImage(image: UIImage?) {
        imageView.image = image
        imageView.stopPosterImageLoadingAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        unselectIfTouchWithinBoundsOfView(touches)
        
        if touchIsWithinBoundsOfView(touches) {
            delegate?.present(index: id, section: section, fromCard: imageView)
        }
    }
}
