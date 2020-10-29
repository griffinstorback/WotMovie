//
//  TouchDelegatingView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-28.
//

import UIKit

class TouchDelegatingView: UIView {

    weak var touchDelegate: UIView? = nil

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else {
            return nil
        }

        guard view === self, let point = touchDelegate?.convert(point, from: self) else {
            return view
        }

        return touchDelegate?.hitTest(point, with: event)
    }
}
