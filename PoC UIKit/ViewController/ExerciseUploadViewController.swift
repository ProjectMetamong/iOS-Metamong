//
//  ExerciseUploadViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit

class ExerciseUploadViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subjectSegmentControl: UISegmentedControl!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var uploadButton: UIButton!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helpers
    func configureUI() {
        self.thumbnailImageView.contentMode = .scaleAspectFill
        self.thumbnailImageView.layer.cornerRadius = 20
        self.thumbnailImageView.clipsToBounds = true
        
        self.uploadButton.layer.cornerRadius = 20
        self.uploadButton.clipsToBounds = true
    }

    // MARK: - IBActions
    

}
