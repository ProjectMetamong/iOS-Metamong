//
//  DetailViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/17.
//

import UIKit
import SnapKit
import Nuke

class DetailViewController: UIViewController {
    
    // MARK: - Properties
    var identifier: Int?
    var viewModel: DetailViewModel?
    
    var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    var timeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 40, weight: .heavy)
        label.textColor = .white
        return label
    }()
    
    var difficultyLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    var creatorLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.isUserInteractionEnabled = false
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        textView.backgroundColor = .clear
        return textView
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = buttonColor.getUIColor
        button.setTitle("시작하기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleStartButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "xmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(self.handleCloseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.backgroundColor = backgroundColor.getUIColor
        
        self.view.addSubview(self.thumbnailImageView)
        self.view.addSubview(self.timeLabel)
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.difficultyLabel)
        self.view.addSubview(self.creatorLabel)
        self.view.addSubview(self.descriptionTextView)
        self.view.addSubview(self.startButton)
        self.view.addSubview(self.closeButton)
        
        guard let identifier = self.identifier else { return }
        self.titleLabel.heroID = "title_\(identifier)"
        self.creatorLabel.heroID = "creator_\(identifier)"
        self.difficultyLabel.heroID = "difficulty_\(identifier)"
        self.timeLabel.heroID = "time_\(identifier)"
        self.thumbnailImageView.heroID = "thumbnail_\(identifier)"
        
        self.view.bringSubviewToFront(self.titleLabel)
        self.view.bringSubviewToFront(self.difficultyLabel)
        self.view.bringSubviewToFront(self.closeButton)
        
        self.thumbnailImageView.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.top)
            $0.left.equalTo(self.view.snp.left)
            $0.right.equalTo(self.view.snp.right)
            $0.height.equalTo(self.thumbnailImageView.snp.width).multipliedBy(1.1)
        }
        
        self.closeButton.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.topMargin)
            $0.right.equalTo(self.view.snp.right).offset(-15)
        }
        
        self.titleLabel.snp.makeConstraints {
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.bottom.equalTo(self.difficultyLabel.snp.top).offset(-8)
        }
        
        self.timeLabel.snp.makeConstraints {
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.top.equalTo(self.view.snp.topMargin)
        }
        
        self.creatorLabel.snp.makeConstraints {
            $0.bottom.equalTo(self.thumbnailImageView.snp.bottom).offset(-30)
            $0.left.equalTo(self.view.snp.left).offset(15)
        }
        
        self.difficultyLabel.snp.makeConstraints {
            $0.centerY.equalTo(self.creatorLabel.snp.centerY)
            $0.right.equalTo(self.view.snp.right).offset(-15)
        }
        
        self.descriptionTextView.snp.makeConstraints {
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.top.equalTo(self.thumbnailImageView.snp.bottom).offset(15)
            $0.bottom.equalTo(self.startButton.snp.top).offset(-15)
        }
        
        self.startButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.snp.bottom).offset(-30)
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.height.equalTo(50)
        }
        
        guard let viewModel = self.viewModel else { return }
        guard let thumbnailURL = viewModel.exercise.thumbnailURL else { return }
        Nuke.loadImage(with: thumbnailURL, into: self.thumbnailImageView)
        self.titleLabel.text = viewModel.exercise.title
        self.timeLabel.text = viewModel.exercise.length
        self.creatorLabel.text = viewModel.exercise.creator
        self.difficultyLabel.text = viewModel.exercise.difficulty
        self.descriptionTextView.text = viewModel.exercise.description
        
        self.titleLabel.textColor = .white
        self.timeLabel.textColor = .white
        self.creatorLabel.textColor = .white
        self.difficultyLabel.textColor = .white
    }
    
    // MARK: - IBActions
    
    @objc func handleCloseButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func handleStartButtonTapped() {
        let exerciseReferenceViewController = ExerciseReferenceViewController()
        
        exerciseReferenceViewController.hero.isEnabled = true
        
        self.navigationController?.hero.navigationAnimationType = .fade
        self.navigationController?.pushViewController(exerciseReferenceViewController, animated: true)
    }
}
