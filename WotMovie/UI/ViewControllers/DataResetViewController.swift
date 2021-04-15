//
//  DataResetViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-04-14.
//

import UIKit

protocol DataResetViewDelegate: NSObjectProtocol {
    func reloadData()
    func presentConfirmationFor(_ type: DataResetRowType, isSecondConfirmation: Bool)
}

class DataResetViewController: UIViewController {
    
    let dataResetPresenter: DataResetPresenterProtocol
    
    let tableView: UITableView

    init(presenter: DataResetPresenterProtocol? = nil) {
        
        dataResetPresenter = presenter ?? DataResetPresenter()
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        dataResetPresenter.setViewDelegate(self)
        
        navigationItem.title = "Data reset"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DataResetTableViewCell")
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
    }
    
    func presentConfirmationAlertViewFor(_ type: DataResetRowType) {
        let alertController = UIAlertController(title: type.rawValue, message: "Are you sure? You can't undo this action.", preferredStyle: .alert)
        
        // do nothing on cancel, just return to guess detail view
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            if type == .resetAll {
                self?.dataResetPresenter.didConfirmResetAllTwice()
            } else {
                self?.dataResetPresenter.didConfirmResetFor(type)
            }
        })
        
        self.present(alertController, animated: true)
    }
    
    // reset all has two confirmations - first one warns that ALL data will be reset.
    func presentFirstConfirmationForResetAll() {
        let alertController = UIAlertController(title: DataResetRowType.resetAll.rawValue, message: "This will reset all data in the application - Movie, TV Show, and Person progress - as well as all items on your Watchlist or Favorites list.", preferredStyle: .alert)
        
        // do nothing on cancel, just return to guess detail view
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        alertController.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.dataResetPresenter.didConfirmResetFor(DataResetRowType.resetAll)
        })
        
        self.present(alertController, animated: true)
    }
}

extension DataResetViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataResetPresenter.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataResetPresenter.getTextForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataResetPresenter.getNumberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DataResetTableViewCell", for: indexPath)
        cell.accessoryType = .none
        cell.accessoryView = nil
        
        let rowType = dataResetPresenter.getTypeForItemAt(indexPath)
        cell.textLabel?.text = rowType.rawValue
        
        if rowType == .resetAll {
            cell.textLabel?.textColor = .systemRed
        } else {
            cell.textLabel?.textColor = .label
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dataResetPresenter.didSelectItemAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DataResetViewController: DataResetViewDelegate {
    func reloadData() {
        tableView.reloadData()
    }
    
    // isSecondConfirmation is only relevant for resetAll, which asks for confirmation twice - because it resets all data, including watchlist and favorites
    func presentConfirmationFor(_ type: DataResetRowType, isSecondConfirmation: Bool = false) {
        switch type {
        case .resetMovies, .resetTVShows, .resetPeople, .resetWatchlist, .resetFavorites:
            presentConfirmationAlertViewFor(type)
        case .resetAll:
            // important: first confirmation attempt for type .all will result in an alert explaning everything will be erased.
            if isSecondConfirmation {
                presentConfirmationAlertViewFor(type)
            } else {
                presentFirstConfirmationForResetAll()
            }
        }
    }
}
