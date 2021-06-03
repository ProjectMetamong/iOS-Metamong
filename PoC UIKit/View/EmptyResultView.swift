//
//  EmptyResultView.swift
//  Metamong
//
//  Created by Seunghun Yang on 2021/06/03.
//

import UIKit
import SnapKit

class EmptyResultView: UIView {

    // MARK: - Properties
    
    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "metamong")
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.text = "검색 결과가 없습니다."
        return label
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.text = "다른 검색어를 입력해주세요."
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
        self.addSubview(self.iconImageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.descriptionLabel)
        
        self.iconImageView.snp.makeConstraints {
            $0.top.equalTo(self.snp.top).offset(20)
            $0.centerX.equalTo(self.snp.centerX)
            $0.width.equalTo(200)
            $0.height.equalTo(200)
        }

        self.titleLabel.snp.makeConstraints {
            $0.top.equalTo(self.iconImageView.snp.bottom).offset(8)
            $0.centerX.equalTo(self.snp.centerX)
        }
        
        self.descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(self.titleLabel.snp.bottom).offset(8)
            $0.centerX.equalTo(self.snp.centerX)
        }
    }
}
