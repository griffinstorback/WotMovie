//
//  SettingsViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

protocol SettingsViewDelegate: NSObjectProtocol {
    func reloadData()
    func reloadSwitchesState()
    func presentDetailViewController(_ vc: UIViewController)
}

class SettingsViewController: UIViewController {
    
    let settingsPresenter: SettingsPresenterProtocol
    
    let tableView: UITableView
    let upgradeButton: ShrinkOnTouchButton
    
    let isDarkModeSwitch: UISwitch
    let isDarkModeSetAutomaticallySwitch: UISwitch

    init(presenter: SettingsPresenterProtocol? = nil) {
        
        settingsPresenter = presenter ?? SettingsPresenter()
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        upgradeButton = ShrinkOnTouchButton()
        
        isDarkModeSwitch = UISwitch()
        isDarkModeSetAutomaticallySwitch = UISwitch()
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        settingsPresenter.setViewDelegate(self)
        
        navigationItem.title = "Settings"
        navigationItem.backBarButtonItem = UIBarButtonItem(image: UIImage(named: "settings_icon"), style: .plain, target: nil, action: nil)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        upgradeButton.setTitle("People", for: .normal)
        upgradeButton.backgroundColor = UIColor(named: "AccentColor") ?? Constants.Colors.defaultBlue
        upgradeButton.titleEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        upgradeButton.setTitleColor(.white, for: .normal)
        upgradeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        upgradeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        upgradeButton.layer.cornerRadius = 10
        upgradeButton.addTarget(self, action: #selector(upgradeButtonPressed), for: .touchUpInside)
        
        isDarkModeSwitch.isOn = settingsPresenter.isDarkModeOn()
        isDarkModeSwitch.addTarget(self, action: #selector(isDarkModeSwitchChanged), for: .valueChanged)
        isDarkModeSetAutomaticallySwitch.isOn = settingsPresenter.isDarkModeSetAutomaticallyOn()
        isDarkModeSetAutomaticallySwitch.addTarget(self, action: #selector(isDarkModeSetAutomaticallySwitchChanged), for: .valueChanged)
    }
    
    // DO NOT CALL THIS IN PRODUCTION
    private func addClearKeychainButtonForTestingPurposes() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "CLEAR KC", style: .plain, target: self, action: #selector(clearKeychain))
    }
    @objc func clearKeychain() { // TEMP - DELETE THIS !
        Keychain.shared[Constants.KeychainStrings.personUpgradePurchasedKey] = nil
    }
    
    @objc func isDarkModeSwitchChanged() {
        settingsPresenter.setDarkModeOn(isDarkModeSwitch.isOn)
    }
    
    @objc func isDarkModeSetAutomaticallySwitchChanged() {
        settingsPresenter.setDarkModeSetAutomaticallyOn(isDarkModeSetAutomaticallySwitch.isOn)
    }
    
    func addUpgradeButton() {
        //navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Upgrade", style: .done, target: self, action: #selector(upgradeButtonPressed))
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: upgradeButton)
        upgradeButton.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: CGSize(width: 75, height: 0))
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadSwitchesState()
        
        // for deselecting row (animated based on progress of dismissal) after returning from detail. it seems to do the same as just deselecting immediately though?
        /*if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedIndexPath, animated: animated)
        }*/
    }
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
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        let rowType = settingsPresenter.getTypeForItemAt(indexPath)
        if rowType == .darkMode || rowType == .darkModeSetAutomatically { // these are cells containing switches - tapping the cell itself shouldn't do anything
            return false
        } else {
            return true
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell", for: indexPath)
        // first reset the accessory view (would do this in custom cell's reuseCell method, but this isn't a custom cell rn)
        cell.accessoryType = .none
        cell.accessoryView = nil
        
        let rowType = settingsPresenter.getTypeForItemAt(indexPath)
        //let isItemSelected = settingsPresenter.itemIsSelected(at: indexPath)
        
        cell.textLabel?.text = rowType.rawValue
        
        switch rowType {
        case .about, .stats, .dataReset:
            cell.accessoryType = .disclosureIndicator
        case .darkMode:
            cell.accessoryView = isDarkModeSwitch
        case .darkModeSetAutomatically:
            cell.accessoryView = isDarkModeSetAutomaticallySwitch
        case .restorePurchases:
            // these should show no accessory view, because they act as buttons
            break
        }
        
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
        
        reloadSwitchesState()
    }
    
    func reloadSwitchesState() {
        isDarkModeSwitch.setOn(settingsPresenter.isDarkModeOn(), animated: true)
        isDarkModeSetAutomaticallySwitch.setOn(settingsPresenter.isDarkModeSetAutomaticallyOn(), animated: true)
    }
    
    func presentDetailViewController(_ vc: UIViewController) {
        navigationController?.pushViewController(vc, animated: true)
    }
}
