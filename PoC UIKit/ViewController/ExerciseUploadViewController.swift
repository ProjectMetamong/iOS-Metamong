//
//  ExerciseUploadViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit

class ExerciseUploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // MARK: - Properties
    
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
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
        
        let thumbnailImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imagePickerTapped(_:)))
        self.thumbnailImageView.isUserInteractionEnabled = true
        self.thumbnailImageView.addGestureRecognizer(thumbnailImageTapGesture)
        
        self.uploadButton.layer.cornerRadius = 20
        self.uploadButton.clipsToBounds = true
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        self.thumbnailImageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Actions
    @objc func imagePickerTapped(_ sender: Any) {
        self.present(self.imagePicker, animated: true, completion: nil)
    }
}
