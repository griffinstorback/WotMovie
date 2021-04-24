//
//  TutorialPageDetailViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-23.
//

import UIKit

class TutorialPageDetailViewController: UIViewController {
    
    let identifier: String

    init(identifier: String) {
        self.identifier = identifier
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
