//
//  PeopleTableViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-21.
//

import UIKit

protocol PeopleTableViewDelegate {
    func getSectionsCount() -> Int
    func getCountForSection(section: Int) -> Int
    func getSectionTitle(for index: Int) -> String?
    func getName(for index: Int, section: Int) -> String?
    func loadImage(for index: Int, section: Int, completion: @escaping (_ image: UIImage?) -> Void)
}

class PeopleTableViewController: UIViewController {
    
    private var delegate: PeopleTableViewDelegate?
    
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
    
    func setDelegate(_ delegate: PeopleTableViewDelegate) {
        self.delegate = delegate
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

extension PeopleTableViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: "PeopleTableViewCell")
        tableView.register(PersonTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: "PeopleTableViewSectionHeader")

        tableView.isUserInteractionEnabled = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.isScrollEnabled = false
        
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
        
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "PeopleTableViewSectionHeader") as! PersonTableSectionHeaderView
        header.setTitle(sectionTitle)
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // if there is no data in this section, display no header
        guard tableView.dataSource?.tableView(tableView, numberOfRowsInSection: section) ?? -1 > 0 else {
            return 0
        }
        
        return 50
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return delegate?.getCountForSection(section: section) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PersonTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PersonTableViewCell
        let section = indexPath.section
        let index = indexPath.row
        
        cell.setName(text: delegate?.getName(for: index, section: section) ?? "")
        delegate?.loadImage(for: index, section: section, completion: cell.setImage(image:))

        return cell
    }
}
