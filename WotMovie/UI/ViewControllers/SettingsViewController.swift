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
    let upgradeButton: ShrinkOnTouchButton

    init(presenter: SettingsPresenterProtocol? = nil) {
        
        settingsPresenter = presenter ?? SettingsPresenter()
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        upgradeButton = ShrinkOnTouchButton()
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        settingsPresenter.setViewDelegate(self)
        
        navigationItem.title = "Settings"
        //self.navigationController?.navigationBar.prefersLargeTitles = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        upgradeButton.setTitle("Upgrade", for: .normal)
        upgradeButton.backgroundColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        upgradeButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        upgradeButton.setTitleColor(.white, for: .normal)
        upgradeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        upgradeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        upgradeButton.layer.cornerRadius = 10
        upgradeButton.addTarget(self, action: #selector(upgradeButtonPressed), for: .touchUpInside)
        
        // TEMP - DELETE THIS AFTER TESTING IAP PURCHASES (OR COMMENT OUT)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CLEAR KC", style: .plain, target: self, action: #selector(clearKeychain))
    }
    
    @objc func clearKeychain() {
        Keychain.shared[Constants.KeychainStrings.personUpgradePurchasedKey] = nil
    }
    
    func addUpgradeButton() {
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upgrade", style: .done, target: self, action: #selector(upgradeButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: upgradeButton)
        upgradeButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 80, height: 0))
    }
    
    func removeUpgradeButton() {
        navigationItem.rightBarButtonItem = nil
    }
    
    private func layoutViews() {
        view.addSubview(tableView)
        tableView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        if settingsPresenter.isPersonCategoryLocked() {
            addUpgradeButton()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func upgradeButtonPressed() {
        let upgradeViewController = UpgradeViewController()
        let navigationController = UINavigationController(rootViewController: upgradeViewController)
        navigationController.modalPresentationStyle = .pageSheet
        
        present(navigationController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
    
    // for deselecting row (animated based on progress of dismissal) after returning from detail. it seems to do the same as just deselecting immediately though?
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
        
        // if user has purchased upgrade, remove the upgrade button from top right.
        if !settingsPresenter.isPersonCategoryLocked() {
            removeUpgradeButton()
        }
    }
    
    func presentDetailViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
