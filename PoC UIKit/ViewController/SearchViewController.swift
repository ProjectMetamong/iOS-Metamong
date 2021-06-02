//
//  ViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit
import Hero
import Nuke
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    let cellIdentifier = "ExerciseCell"
    let searchController = UISearchController()
    let viewModel: SearchViewModel = SearchViewModel()
    let disposeBag: DisposeBag = DisposeBag()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var resultCollectionView: UICollectionView!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.bindUI()
        
        self.resultCollectionView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
        self.resultCollectionView.register(ExerciseCollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.navigationItem.searchController = self.searchController
        self.navigationController?.isHeroEnabled = true
    }
    
    func bindUI() {
        self.viewModel.exerciseObservable
            .bind(to: self.resultCollectionView.rx.items(cellIdentifier: self.cellIdentifier, cellType: ExerciseCollectionViewCell.self)) { index, item, cell in
                cell.layer.cornerRadius = cornerRadius
                cell.layer.masksToBounds = true
                
                cell.titleLabel.text = item.title
                cell.creatorLabel.text = item.creator
                cell.difficultyLabel.text = item.difficulty
                cell.timeLabel.text = item.length.msToTimeString()
                
                guard let thumbnailURL = URL(string: AWSS3Url + AWSS3BucketName + "/\(item.id).jpeg") else { return }
                Nuke.loadImage(with: thumbnailURL, into: cell.thumbnailImageView)
                cell.thumbnailImageView.contentMode = .scaleAspectFill
                
                cell.titleLabel.heroID = "title_\(item.id)"
                cell.creatorLabel.heroID = "creator_\(item.id)"
                cell.difficultyLabel.heroID = "difficulty_\(item.id)"
                cell.timeLabel.heroID = "time_\(item.id)"
                cell.thumbnailImageView.heroID = "thumbnail_\(item.id)"
            }
            .disposed(by: self.disposeBag)
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
        let exercise = self.viewModel.exerciseObservable.value[indexPath.row]
        let detailViewController = DetailViewController()
        detailViewController.hero.isEnabled = true
        detailViewController.viewModel = DetailViewModel(exercise: exercise)
        
        self.navigationController?.hero.navigationAnimationType = .fade
        self.navigationController?.pushViewController(detailViewController, animated: true)
    }
}
