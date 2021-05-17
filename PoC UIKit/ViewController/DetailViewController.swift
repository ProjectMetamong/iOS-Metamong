//
//  DetailViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/17.
//

import UIKit

class DetailViewController: UIViewController {
    
    // MARK: - Properties
    var identifier: Int?
    
    // MARK: - IBOutlets
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var difficultyLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    
    // MARK: - Lifecycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    // MARK: - Helpers
    
    func configureUI() {
        self.cardView.layer.cornerRadius = cornerRadius
        self.cardView.layer.masksToBounds = true
        
        self.startButton.layer.cornerRadius = cornerRadius
        self.startButton.layer.masksToBounds = true
        
        guard let identifier = self.identifier else { return }
        self.titleLabel.heroID = "title_\(identifier)"
        self.creatorLabel.heroID = "creator_\(identifier)"
        self.difficultyLabel.heroID = "difficulty_\(identifier)"
        self.timeLabel.heroID = "time_\(identifier)"
        self.cardView.heroID = "thumbnail_\(identifier)"
        
        self.titleLabel.text = "벤치프레스"
        self.creatorLabel.text = "말왕"
        self.difficultyLabel.text = "중급자"
        self.timeLabel.text = "13m30s"
    }
    
    // MARK: - IBActions
    
    @IBAction func dismissButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
