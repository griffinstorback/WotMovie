//
//  StatsViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-14.
//

import UIKit

protocol StatsViewDelegate: NSObjectProtocol {
    func reloadData()
}

class StatsViewController: UIViewController {
    
    let statsPresenter: StatsPresenterProtocol
    
    let tableView: UITableView

    init(presenter: StatsPresenterProtocol? = nil) {
        statsPresenter = presenter ?? StatsPresenter()
        
        tableView = UITableView(frame: .zero, style: .grouped)
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        title = "Stats"
        
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StatsTableViewCell")
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        statsPresenter.loadStats()
    }
    
    private func layoutViews() {
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}

extension StatsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return statsPresenter.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return statsPresenter.getTextForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statsPresenter.getNumberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // To make the detailTextLabel visible, which contains the count for a stat category, we don't register the identifier,
        // and we don't call dequeueReusableCell with indexPath; this means first time loading cell will be nil,
        // so we provide a cell with appropriate style on first load.
        var optionalCell = tableView.dequeueReusableCell(withIdentifier: "StatsTableViewCell")
        if optionalCell == nil {
            optionalCell = UITableViewCell(style: .value1, reuseIdentifier: "StatsTableViewCell")
        }
        guard let cell = optionalCell else { return UITableViewCell() }
        
        let indentLevel = statsPresenter.getIndentLevelForItemAt(indexPath)
        cell.indentationLevel = indentLevel
        
        let text = statsPresenter.getTextForItemAt(indexPath)
        cell.textLabel?.text = text
        cell.textLabel?.font = indentLevel == 0 ? UIFont.systemFont(ofSize: 18, weight: .bold) : UIFont.systemFont(ofSize: 18)
        
        let countForStatType = statsPresenter.getCountForStatTypeAt(indexPath)
        //cell.accessoryType = .disclosureIndicator
        cell.detailTextLabel?.text = String(countForStatType)
        cell.detailTextLabel?.font = indentLevel == 0 ? UIFont.systemFont(ofSize: 18, weight: .bold) : UIFont.systemFont(ofSize: 18)
        cell.detailTextLabel?.textColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        statsPresenter.didSelectItemAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension StatsViewController: StatsViewDelegate {
    func reloadData() {
        tableView.reloadData()
    }
}
