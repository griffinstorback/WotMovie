//
//  SortGridViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-02-06.
//

import UIKit

// VC presenting SortGridViewController needs to adhere to this protocol and set self as resultsDelegate in order to get results
protocol SortGridViewResultsDelegate {
    func didSaveWithParameters(_ sortParameters: SortParameters)
}

protocol SortGridViewDelegate: NSObjectProtocol {
    func reloadData()
}

class SortGridViewController: UIViewController {
    let sortGridPresenter: SortGridPresenterProtocol
        
    var resultsDelegate: SortGridViewResultsDelegate?

    let tableView: UITableView
    
    init(sortParameters: SortParameters, presenter: SortGridPresenterProtocol? = nil) {
        sortGridPresenter = presenter ?? SortGridPresenter(sortParameters: sortParameters)
        
        tableView = UITableView(frame: .zero, style: .insetGrouped)
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        sortGridPresenter.setViewDelegate(self)
        
        // need line below to remove empty space which appears above tableview when style == grouped (or insetgrouped)
        tableView.contentInsetAdjustmentBehavior = .never
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SortGridTableViewCell")
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        
        let saveButton = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(saveSortSettings))
        navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonPressed))
        navigationItem.leftBarButtonItem = cancelButton
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
        navigationItem.title = "Sort"
    }
    
    @objc func saveSortSettings() {
        if let resultsDelegate = resultsDelegate {
            resultsDelegate.didSaveWithParameters(sortGridPresenter.getSortParameters())
        } else {
            print("** WARNING: SortGridViewController save button was pressed, but no results delegate was set, so nothing will happen.")
        }
        self.dismiss(animated: true)
    }
    
    @objc func cancelButtonPressed() {
        self.dismiss(animated: true)
    }
}

extension SortGridViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sortGridPresenter.getNumberOfSections()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortGridPresenter.getTextForHeaderInSection(section)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortGridPresenter.getNumberOfItemsInSection(section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortGridTableViewCell", for: indexPath)
        let text = sortGridPresenter.getTextForItemAt(indexPath)
        let isItemSelected = sortGridPresenter.itemIsSelected(at: indexPath)
        
        cell.textLabel?.text = text
        cell.accessoryType = isItemSelected ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sortGridPresenter.didSelectItemAt(indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SortGridViewController: SortGridViewDelegate {
    func reloadData() {
        tableView.reloadData()
    }
}
