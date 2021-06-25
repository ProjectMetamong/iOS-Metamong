//
//  ExerciseCollectionViewCell.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit
import SnapKit

class ExerciseCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Properties
    
    lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray3
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.text = "테스트"
        return label
    }()
    
    lazy var difficultyLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    lazy var creatorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    // MARK: - LifeCycles
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.backgroundColor = .systemGray3
        
        self.addSubview(self.thumbnailImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.difficultyLabel)
        self.addSubview(self.timeLabel)
        self.addSubview(self.creatorLabel)
        
        self.thumbnailImageView.snp.makeConstraints {
            $0.top.equalTo(self.snp.top)
            $0.left.equalTo(self.snp.left)
            $0.right.equalTo(self.snp.right)
            $0.bottom.equalTo(self.snp.bottom)
        }
        
        self.difficultyLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.snp.bottom).offset(-15)
            $0.right.equalTo(self.snp.right).offset(-12)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.snp.bottom).offset(-35.5)
            $0.right.equalTo(self.snp.right).offset(-12)
            $0.left.greaterThanOrEqualTo(self.snp.left).offset(12)
        }
        
        self.timeLabel.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(12)
            $0.left.equalTo(self.snp.left).offset(12)
        }
        
        self.creatorLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.snp.bottom).offset(-15)
            $0.left.equalTo(self.snp.left).offset(12)
            $0.right.lessThanOrEqualTo(self.difficultyLabel.snp.left).offset(-12)
        }
        
    }
}
