//
//  ViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit
import Hero
import Nuke

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    let cellIdentifier = "ExerciseCell"
    let searchController = UISearchController()
    let viewModel: SearchViewModel = SearchViewModel()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        self.resultCollectionView.dataSource = self
        self.resultCollectionView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.backgroundColor = backgroundColor.getUIColor
        self.navigationController?.navigationBar.backgroundColor = backgroundColor.getUIColor
        self.navigationController?.navigationBar.barTintColor = backgroundColor.getUIColor
        self.tabBarController?.tabBar.barTintColor = backgroundColor.getUIColor
        self.resultCollectionView.backgroundColor = backgroundColor.getUIColor
        
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        self.navigationController?.isHeroEnabled = true
    }

    // MARK: - IBAction
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.exercises.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ExerciseCollectionViewCell
        
        let exercise = self.viewModel.exercises[indexPath.row]
        
        cell.layer.cornerRadius = cornerRadius
        cell.layer.masksToBounds = true
        
        cell.titleLabel.text = exercise.title
        cell.creatorLabel.text = exercise.creator
        cell.difficultyLabel.text = exercise.difficulty
        cell.timeLabel.text = exercise.length
        
        guard let thumbnailURL = exercise.thumbnailURL else { return UICollectionViewCell() }
        Nuke.loadImage(with: thumbnailURL, into: cell.thumbnailImageView)
        cell.thumbnailImageView.contentMode = .scaleAspectFill
        
        cell.titleLabel.heroID = "title_\(indexPath.row)"
        cell.creatorLabel.heroID = "creator_\(indexPath.row)"
        cell.difficultyLabel.heroID = "difficulty_\(indexPath.row)"
        cell.timeLabel.heroID = "time_\(indexPath.row)"
        cell.thumbnailImageView.heroID = "thumbnail_\(indexPath.row)"
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 45) / 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 15, bottom: 15, right: 15)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let exercise = self.viewModel.exercises[indexPath.row]
        let detailViewController = DetailViewController()
        
        detailViewController.hero.isEnabled = true
        detailViewController.identifier = indexPath.row
        
        detailViewController.viewModel = DetailViewModel(exercise: exercise)
        
        self.navigationController?.hero.navigationAnimationType = .fade
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
