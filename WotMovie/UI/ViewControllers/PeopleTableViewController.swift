//
//  PeopleTableViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-21.
//

import UIKit

class PeopleTableViewController: UIViewController {
    
    private let guessDetailPresenter: GuessDetailPresenter
    
    private var tableView: ContentSizedTableView!
    
    init(guessDetailPresenter: GuessDetailPresenter) {
        self.guessDetailPresenter = guessDetailPresenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        layoutTableView()
    }
    
    func reloadTableViewData() {
        tableView.reloadData()
    }
}

extension PeopleTableViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView = ContentSizedTableView()
        
        tableView.register(PersonTableViewCell.self, forCellReuseIdentifier: "PeopleTableViewCell")
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
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Cast"
        } else if section == 1 {
            return "Crew"
        }
        
        return nil
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return guessDetailPresenter.getCastCount()
        } else if section == 1 {
            return guessDetailPresenter.getCrewCount()
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return PersonTableViewCell.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PeopleTableViewCell", for: indexPath) as! PersonTableViewCell
        let section = indexPath.section
        let index = indexPath.row
        
        if section == 0 {
            cell.setName(text: guessDetailPresenter.getCastMember(for: index)?.name ?? "")
            guessDetailPresenter.loadCastPersonImage(index: index, completion: cell.setImage)
        } else if section == 1 {
            cell.setName(text: guessDetailPresenter.getCrewMember(for: index)?.name ?? "")
            cell.setSubtitle(text: guessDetailPresenter.getCrewMember(for: index)?.job ?? "")
            guessDetailPresenter.loadCrewPersonImage(index: index, completion: cell.setImage)
        }

        return cell
    }
}
