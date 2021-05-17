//
//  ViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    let cellIdentifier = "ExerciseCell"
    let searchController = UISearchController()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
        self.resultCollectionView.dataSource = self
        self.resultCollectionView.delegate = self
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.navigationItem.searchController = self.searchController
    }

    // MARK: - IBAction
}

// MARK: - UICollectionViewDataSource

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ExerciseCollectionViewCell
        
        cell.layer.cornerRadius = cornerRadius
        cell.layer.masksToBounds = true
        
        cell.titleLabel.text = "벤치프레스"
        cell.creatorLabel.text = "말왕"
        cell.difficultyLabel.text = "중급자"
        cell.timeLabel.text = "13m30s"
        cell.thumbnailImageView.image = #imageLiteral(resourceName: "Squat")
        cell.thumbnailImageView.contentMode = .scaleAspectFill
        
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
