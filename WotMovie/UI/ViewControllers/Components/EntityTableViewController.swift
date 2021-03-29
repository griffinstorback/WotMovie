//
//  EntityTableViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-21.
//

import UIKit

protocol EntityTableViewDelegate: NSObjectProtocol {
    func getSectionsCount() -> Int
    func getCountForSection(section: Int) -> Int
    func getSectionTitle(for index: Int) -> String?
    func getItem(for index: Int, section: Int) -> Entity?
    func loadImage(for index: Int, section: Int, completion: @escaping (_ image: UIImage?, _ imagePath: String?) -> Void)
}

class EntityTableViewController: DetailPresenterViewController {
    
    private weak var delegate: EntityTableViewDelegate?
    
    private var tableView: ContentSizedTableView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        
        tableView = ContentSizedTableView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        layoutTableView()
    }
    
    func setDelegate(_ delegate: EntityTableViewDelegate) {
        self.delegate = delegate
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

extension EntityTableViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func setupTableView() {
        tableView.register(EntityTableViewCell.self, forCellReuseIdentifier: "EntityTableViewCell")
        tableView.register(EntityTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "EntityTableSectionHeader")

        //tableView.isUserInteractionEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        // Set scroll to enabled after view appears (otherwise theres a bug where first tap on cell
        // doesn't register).
        tableView.delaysContentTouches = true
        tableView.isScrollEnabled = false
        tableView.bounces = true
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func layoutTableView() {
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return delegate?.getSectionsCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionTitle = delegate?.getSectionTitle(for: section) else {
            return nil
        }
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "EntityTableSectionHeader") as! EntityTableSectionHeaderView
        header.setTitle(sectionTitle)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // if there is no data in this section, display no header
        guard tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section) ?? -1 > 0 else {
            return 0
        }
        
        return EntityTableSectionHeaderView.height
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.getCountForSection(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return EntityTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EntityTableViewCell", for: indexPath) as! EntityTableViewCell
        let section = indexPath.section
        let index = indexPath.row
        
        guard let item = delegate?.getItem(for: index, section: section) else {
            return cell
        }
        
        cell.setName(text: item.name)
        cell.setImagePath(imagePath: item.posterPath ?? "")
        delegate?.loadImage(for: index, section: section, completion: cell.setImage)
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("**** DID DESELECT ITEM: \(delegate?.getItem(for: indexPath.row, section: indexPath.section)?.name)")
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("**** DID SELECT ITEM: \(delegate?.getItem(for: indexPath.row, section: indexPath.section)?.name)")
        let cell = tableView.cellForRow(at: indexPath) as! EntityTableViewCell
        let section = indexPath.section
        let index = indexPath.row
        
        guard let item = delegate?.getItem(for: index, section: section) else {
            return
        }
        
        let guessDetailViewController: GuessDetailViewController
        
        switch item.type {
        case .movie, .tvShow:
            guessDetailViewController = TitleDetailViewController(item: item, state: .revealedWithNoNextButton)
        case .person:
            guessDetailViewController = PersonDetailViewController(item: item, state: .revealedWithNoNextButton)
        }
        
        // Presenter nil because no entity presented from this VC will start hidden, therefore will never need
        // to call setRevealed() to update posterimage.
        present(guessDetailViewController, fromCard: cell.profileImageView, startHidden: false, transitionPresenter: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
