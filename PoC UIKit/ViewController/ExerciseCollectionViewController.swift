//
//  ViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit

class ExerciseCollectionViewController: UIViewController {
    
    // MARK: - Properties
    let cellIdentifier = "ExerciseCell"
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var exerciseCollectionView: UICollectionView!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.exerciseCollectionView.dataSource = self
        self.exerciseCollectionView.delegate = self
        self.exerciseCollectionView.register(ExerciseCollectionViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        
        configureUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        
    }

    // MARK: - IBAction
}

// MARK: - UICollectionViewDataSource

extension ExerciseCollectionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ExerciseCollectionViewCell
        
        cell.backgroundColor = .red
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ExerciseCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 45) / 2
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
    }
}
