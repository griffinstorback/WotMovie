//
//  GuessViewController.swift
//  WotMovie
//
//  Created by Griffin Storback on 2020-10-13.
//

import UIKit

class GuessViewController: UIViewController {
    
    private let guessViewPresenter = GuessPresenter(networkManager: NetworkManager.shared)
    
    private var tableView: UITableView!
    private var selectGenreLabel: UILabel!
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guessViewPresenter.setViewDelegate(guessViewDelegate: self)
        
        view.backgroundColor = .white
        
        setupNavigationView()
        setupTableView()
        setupSelectGenreLabel()
        
        guessViewPresenter.loadGenreList()
    }
    
    func setupNavigationView() {
        title = "WotMovie"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupSelectGenreLabel() {
        selectGenreLabel = UILabel()
        selectGenreLabel.backgroundColor = .white
        selectGenreLabel.text = "Select a genre to guess from"
        selectGenreLabel.numberOfLines = 0
        self.view.addSubview(selectGenreLabel)
        
        selectGenreLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: tableView.topAnchor, trailing: view.trailingAnchor, padding: UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5))
    }
}

extension GuessViewController: GuessViewDelegate {
    func presentGuessGridView(for genre: Genre) {
        let guessGridViewController = GuessGridViewController(for: genre)
        
        navigationController?.pushViewController(guessGridViewController, animated: true)
    }
    
    func displayErrorLoadingGenres() {
        print("displayErrorLoadingGenres")
    }
    
    func reloadData() {
        tableView.reloadData()
    }
}

extension GuessViewController: UITableViewDelegate, UITableViewDataSource {
    func setupTableView() {
        tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "GenreListTableViewCell")
        
        self.view.addSubview(tableView)
        
        tableView.anchor(top: nil, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Movies"
        } else if section == 1 {
            return "TV Shows"
        }
        
        return ""
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            guessViewPresenter.showGenreDetail(index: indexPath.row, isMovie: true)
        } else if indexPath.section == 1 {
            guessViewPresenter.showGenreDetail(index: indexPath.row, isMovie: false)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return guessViewPresenter.movieGenresCount
        } else if section == 1 {
            return guessViewPresenter.tvShowGenresCount
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GenreListTableViewCell", for: indexPath) as UITableViewCell
        var genre: Genre
        
        if indexPath.section == 0 {
            genre = guessViewPresenter.genreForMovie(index: indexPath.row)
            cell.textLabel?.text = genre.name
            return cell
        } else if indexPath.section == 1 {
            genre = guessViewPresenter.genreForTVShow(index: indexPath.row)
            cell.textLabel?.text = genre.name
            return cell
        }
        
        return cell
    }
}
