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
import SnapKit

class SearchViewController: UIViewController {
    
    // MARK: - Properties
    
    let cellIdentifier = "ExerciseCell"
    let viewModel: SearchViewModel = SearchViewModel()
    let disposeBag: DisposeBag = DisposeBag()
    
    lazy var resultCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = backgroundColor.getUIColor
        collectionView.register(ExerciseCollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        collectionView.delegate = self
        collectionView.backgroundView = self.emptyResultView
        collectionView.backgroundView?.isHidden = true
        collectionView.keyboardDismissMode = .onDrag
        collectionView.refreshControl = self.refreshControl
        return collectionView
    }()
    
    lazy var searchController: UISearchController = {
        let searchController = UISearchController()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshResults), for: .valueChanged)
        return refreshControl
    }()
    
    lazy var emptyResultView: EmptyResultView = EmptyResultView()
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.bindUI()    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.addSubview(self.resultCollectionView)
        
        self.view.backgroundColor = backgroundColor.getUIColor
        self.navigationController?.navigationBar.backgroundColor = backgroundColor.getUIColor
        self.navigationController?.navigationBar.barTintColor = backgroundColor.getUIColor
        self.tabBarController?.tabBar.barTintColor = backgroundColor.getUIColor
        
        self.navigationItem.searchController = self.searchController
        self.navigationController?.isHeroEnabled = true
        
        self.resultCollectionView.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.topMargin)
            $0.bottom.equalTo(self.view.snp.bottomMargin)
            $0.left.equalTo(self.view.snp.left)
            $0.right.equalTo(self.view.snp.right)
        }
    }
    
    func bindUI() {
        self.viewModel.exerciseObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.resultCollectionView.backgroundView?.isHidden = $0.count != 0 ? true : false
            })
            .disposed(by: self.disposeBag)
        
        self.searchController.searchBar.rx.text.orEmpty
            .debounce(RxTimeInterval.seconds(1), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .filter({ (text) -> Bool in
                text != ""
            })
            .subscribe(onNext: { text in
                self.resultCollectionView.setContentOffset(CGPoint(x:0,y:0), animated: false)
                self.searchController.searchBar.endEditing(true)
                self.searchController.isActive = false
                self.navigationItem.title = text
                self.viewModel.searchExercises(keyword: text)
            })
            .disposed(by: disposeBag)
        
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
    
    // MARK: - Actions
    
    @objc func refreshResults() {
        self.viewModel.refreshExercises()
        self.refreshControl.endRefreshing()
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

