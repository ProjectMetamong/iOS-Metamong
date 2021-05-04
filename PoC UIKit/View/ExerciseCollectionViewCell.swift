//
//  ExerciseCollectionViewCell.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit

class ExerciseCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Lifecycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        print("ExerciseCollectionViewCell ConfigureUI called")
    }
}
