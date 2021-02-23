//
//  SettingsViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

protocol SettingsViewDelegate: NSObjectProtocol {
    func reloadData()
    func presentDetailViewController(_ vc: UIViewController)
}

class SettingsViewController: UIViewController {
    
    let settingsPresenter: SettingsPresenterProtocol
    
    let tableView: UITableView

    init(presenter: SettingsPresenterProtocol? = nil) {
        
        settingsPresenter = presenter ?? SettingsPresenter()
        
        tableView = UITableView(frame: .zero, style: .grouped)
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        settingsPresenter.setViewDelegate(self)
        
        navigationItem.title = "Settings"
        //self.navigationController?.navigationBar.prefersLargeTitles = true
        
        let upgradeButton = UIBarButtonItem(title: "Upgrade", style: .done, target: self, action: #selector(upgradeButtonPressed))
        navigationItem.rightBarButtonItem = upgradeButton
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
        
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func layoutViews() {
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func upgradeButtonPressed() {
        print("*** UPGRADE BUTTON PRESSED")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
    
    // for deselecting row after returning from detail. it seems to do the same as just deselecting immediately though?
    /*override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }
    }*/
}

extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingsPresenter.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingsPresenter.getTextForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsPresenter.getNumberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath)
        let text = settingsPresenter.getTextForItemAt(indexPath)
        //let isItemSelected = settingsPresenter.itemIsSelected(at: indexPath)
        
        cell.textLabel?.text = text
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        settingsPresenter.didSelectItemAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SettingsViewController: SettingsViewDelegate {
    func reloadData() {
        tableView.reloadData()
    }
    
    func presentDetailViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
