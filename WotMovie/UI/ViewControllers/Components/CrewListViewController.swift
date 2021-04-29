//
//  CrewListView.swift
//  WotMovie
//
//  Created by Griffin Storback on 2021-03-30.
//

import UIKit

protocol CrewListViewDelegate: NSObjectProtocol {
    func getCrewTypeStringToDisplay(for section: CrewTypeSection) -> String?
    
    func getDirectors() -> [CrewMember]
    func getProducers() -> [CrewMember]
    func getWriters() -> [CrewMember]
    
    func loadImage(for index: Int, section: CrewTypeSection, completion: @escaping (_ image: UIImage?) -> Void)
    
    func getCrewMember(for index: Int, section: CrewTypeSection) -> CrewMember?
}

enum CrewListViewState {
    case itemIsRevealedOrGuessed
    case itemIsHiddenSoModalsShouldBePrevented
}

class CrewListViewController: DetailPresenterViewController {
    
    // e.g, if 10, and there are 15 producers, will only show first 10. Set to nil if should remove limit. Limit is there because was worried
    // about putting limits in case there was some show with 1000 producers or something ridiculous - this is not a table view, so it's not optimized
    // for large amounts of data (also, why would user want to see a list of 1000 producers?)
    static let maxAmountToDisplayInEachJobSection: Int? = 15
    
    var state: CrewListViewState = .itemIsHiddenSoModalsShouldBePrevented
    
    weak var delegate: CrewListViewDelegate?
    
    let mainStack: UIStackView
    
    let directorsStack: UIStackView
    let directorsTitleLabel: UILabel
    let directorsTitleLabelContainer: UIView
    var directorsCrewListRows: [CrewListRow] = []
    
    let producersStack: UIStackView
    let producersTitleLabel: UILabel
    let producersTitleLabelContainer: UIView
    var producersCrewListRows: [CrewListRow] = []
    
    let writersStack: UIStackView
    let writersTitleLabel: UILabel
    let writersTitleLabelContainer: UIView
    var writersCrewListRows: [CrewListRow] = []

    init() {
        mainStack = UIStackView()
        
        directorsStack = UIStackView()
        directorsTitleLabel = UILabel()
        directorsTitleLabelContainer = UIView()
        
        producersStack = UIStackView()
        producersTitleLabel = UILabel()
        producersTitleLabelContainer = UIView()
        
        writersStack = UIStackView()
        writersTitleLabel = UILabel()
        writersTitleLabelContainer = UIView()
        
        super.init(nibName: nil, bundle: nil)
        
        setupViews()
        layoutViews()
    }
    
    private func setupViews() {
        mainStack.axis = .vertical
        mainStack.alignment = .fill
        mainStack.spacing = 20
        
        directorsStack.axis = .vertical
        directorsStack.alignment = .fill
        directorsTitleLabel.font = Constants.Fonts.detailViewSectionHeader
        directorsTitleLabel.text = "Director"
        
        producersStack.axis = .vertical
        producersStack.alignment = .fill
        producersTitleLabel.font = Constants.Fonts.detailViewSectionHeader
        producersTitleLabel.text = "Producer"
        
        writersStack.axis = .vertical
        writersStack.alignment = .fill
        writersTitleLabel.font = Constants.Fonts.detailViewSectionHeader
        writersTitleLabel.text = "Writer"
    }
    
    private func layoutViews() {
        view.addSubview(mainStack)
        mainStack.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)
        
        mainStack.addArrangedSubview(directorsStack)
        directorsStack.addArrangedSubview(directorsTitleLabelContainer)
        directorsTitleLabelContainer.addSubview(directorsTitleLabel)
        directorsTitleLabel.anchor(top: directorsTitleLabelContainer.topAnchor, leading: directorsTitleLabelContainer.leadingAnchor, bottom: directorsTitleLabelContainer.bottomAnchor, trailing: directorsTitleLabelContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        directorsStack.isHidden = true
        
        mainStack.addArrangedSubview(writersStack)
        writersStack.addArrangedSubview(writersTitleLabelContainer)
        writersTitleLabelContainer.addSubview(writersTitleLabel)
        writersTitleLabel.anchor(top: writersTitleLabelContainer.topAnchor, leading: writersTitleLabelContainer.leadingAnchor, bottom: writersTitleLabelContainer.bottomAnchor, trailing: writersTitleLabelContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        writersStack.isHidden = true

        mainStack.addArrangedSubview(producersStack)
        producersStack.addArrangedSubview(producersTitleLabelContainer)
        producersTitleLabelContainer.addSubview(producersTitleLabel)
        producersTitleLabel.anchor(top: producersTitleLabelContainer.topAnchor, leading: producersTitleLabelContainer.leadingAnchor, bottom: producersTitleLabelContainer.bottomAnchor, trailing: producersTitleLabelContainer.trailingAnchor, padding: UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0))
        producersStack.isHidden = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setDelegate(_ delegate: CrewListViewDelegate) {
        self.delegate = delegate
        reloadData()
    }
    
    public func reloadData() {
        if let directors = delegate?.getDirectors(), directors.count > 0 {
            for (index, director) in directors.enumerated() {
                let directorRow = CrewListRow(frame: .zero, id: index, section: .director)
                directorRow.setNameLabel(text: director.name)
                delegate?.loadImage(for: index, section: .director, completion: directorRow.setImage)
                directorRow.setDelegate(self)
                directorsStack.addArrangedSubview(directorRow)
                
                // break if there is a limit set, and if it has been reached.
                if let max = CrewListViewController.maxAmountToDisplayInEachJobSection, index+1 >= max { break }
            }
            directorsTitleLabel.text = delegate?.getCrewTypeStringToDisplay(for: .director) ?? "Director"
            directorsStack.isHidden = false
        } else {
            // don't show directors stack
            directorsStack.isHidden = true
        }
        
        if let writers = delegate?.getWriters(), writers.count > 0 {
            for (index, writer) in writers.enumerated() {
                let writerRow = CrewListRow(frame: .zero, id: index, section: .writer)
                writerRow.setNameLabel(text: writer.name)
                delegate?.loadImage(for: index, section: .writer, completion: writerRow.setImage)
                writerRow.setDelegate(self)
                writersStack.addArrangedSubview(writerRow)
                
                // break if there is a limit set, and if it has been reached.
                if let max = CrewListViewController.maxAmountToDisplayInEachJobSection, index+1 >= max { break }
            }
            writersTitleLabel.text = delegate?.getCrewTypeStringToDisplay(for: .writer) ?? "Writer"
            writersStack.isHidden = false
        } else {
            // don't show writers stack
            writersStack.isHidden = true
        }
        
        if let producers = delegate?.getProducers(), producers.count > 0 {
            for (index, producer) in producers.enumerated() {
                let producerRow = CrewListRow(frame: .zero, id: index, section: .producer)
                producerRow.setNameLabel(text: producer.name)
                delegate?.loadImage(for: index, section: .producer, completion: producerRow.setImage)
                producerRow.setDelegate(self)
                producersStack.addArrangedSubview(producerRow)
                
                // break if there is a limit set, and if it has been reached.
                if let max = CrewListViewController.maxAmountToDisplayInEachJobSection, index+1 >= max { break }
            }
            producersTitleLabel.text = delegate?.getCrewTypeStringToDisplay(for: .producer) ?? "Producer"
            producersStack.isHidden = false
        } else {
            // don't show producers stack
            producersStack.isHidden = true
        }
    }
}

extension CrewListViewController: CrewListRowDelegate {
    func present(index: Int, section: CrewTypeSection, fromCard: UIView) {
        guard state == .itemIsRevealedOrGuessed else {
            BriefAlertView(title: "Guess or Reveal first").present()
            return
        }
        
        guard let crewMember = delegate?.getCrewMember(for: index, section: section) else { return }
        
        let personDetailViewController = PersonDetailViewController(item: crewMember, state: .revealedWithNoNextButton)
        
        present(personDetailViewController, fromCard: fromCard, startHidden: false, transitionPresenter: nil)
    }
}
