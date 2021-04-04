//
//  BriefAlertVIew.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-01.
//

import UIKit

class BriefAlertView: UIView {
    
    weak var presentWindow: UIWindow? = UIApplication.shared.windows.first
    var completion: (() -> Void)? = nil
    
    var presentDismissScale: CGFloat = 0.8
    var presentDismissDuration: TimeInterval = 0.2

    private lazy var backgroundView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        view.isUserInteractionEnabled = false
        return view
    }()
    
    private let iconView: UIImageView
    private var titleLabel: UILabel
    
    
    public init(title: String) {
        iconView = UIImageView()
        titleLabel = UILabel()
        
        super.init(frame: .zero)
        
        setupViews(title: title)
        //layoutViews()
    }
    
    private func setupViews(title: String) {
        preservesSuperviewLayoutMargins = false
        insetsLayoutMarginsFromSafeArea = false
        layer.masksToBounds = true
        layer.cornerRadius = 10
        backgroundColor = .clear
        
        titleLabel.text = title
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .secondaryLabel
    }
    
    private func layoutViews() {
        anchorToCenter(yAnchor: presentWindow?.centerYAnchor, xAnchor: presentWindow?.centerXAnchor)
        anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 200, height: 200))
        
        addSubview(backgroundView)
        backgroundView.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        
        addSubview(titleLabel)
        titleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func present(duration: TimeInterval = 1.5, impactHaptic: UIImpactFeedbackGenerator.FeedbackStyle? = nil, notificationHaptic: UINotificationFeedbackGenerator.FeedbackType? = nil, completion: (() -> Void)? = nil) {
        guard let window = self.presentWindow else { return }
        window.addSubview(self)
        layoutViews()
        
        self.completion = completion
        
        alpha = 0
        transform = transform.scaledBy(x: self.presentDismissScale, y: self.presentDismissScale)
        
        // haptic
        
        UIView.animate(withDuration: presentDismissDuration, animations: {
            self.alpha = 1
            self.transform = .identity
        }, completion: { finished in
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                self.dismiss()
            }
        })
    }
    
    public func dismiss() {
        UIView.animate(withDuration: presentDismissDuration, animations: {
            self.alpha = 0
            self.transform = self.transform.scaledBy(x: self.presentDismissScale, y: self.presentDismissScale)
        }, completion: { [weak self] finished in
            self?.removeFromSuperview()
            self?.completion?()
        })
    }
}
