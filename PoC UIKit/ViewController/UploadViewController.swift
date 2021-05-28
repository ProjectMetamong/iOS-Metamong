//
//  ExerciseUploadViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit
import SnapKit

class UploadViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    // MARK: - Properties
    
    private var viewModel: UploadViewModel = UploadViewModel()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    var detailTextView: UITextView = {
        let textView = UITextView()
        textView.text = "동해물과 백두산이 마르고 닳도록 하느님이 보우하사 우리나라 만세 무궁화 삼천리 화려강산 대한사람 대한으로 길이보전하세"
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        textView.backgroundColor = .clear
        return textView
    }()
    
    lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = buttonColor.getUIColor
        button.setTitle("영상 선택 및 업로드", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleUploadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        return gesture
    }()
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subjectSegmentControl: UISegmentedControl!
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.navigationController?.isHeroEnabled = true
        
        self.view.addSubview(detailTextView)
        self.view.addSubview(uploadButton)
        
        self.view.addGestureRecognizer(tapGesture)
        
        self.detailTextView.snp.makeConstraints {
            $0.top.equalTo(self.thumbnailImageView.snp.bottom).offset(15)
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.bottom.equalTo(self.uploadButton.snp.top).offset(15)
        }
        
        self.uploadButton.snp.makeConstraints {
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.bottom.equalTo(self.view.snp.bottomMargin).offset(-15)
            $0.height.equalTo(50)
        }
        
        self.view.backgroundColor = backgroundColor.getUIColor
        self.navigationController?.navigationBar.backgroundColor = backgroundColor.getUIColor
        self.navigationController?.navigationBar.barTintColor = backgroundColor.getUIColor
        
        self.thumbnailImageView.contentMode = .scaleAspectFill
        self.thumbnailImageView.layer.cornerRadius = cornerRadius
        self.thumbnailImageView.clipsToBounds = true
        
        let thumbnailImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.imagePickerTapped(_:)))
        self.thumbnailImageView.isUserInteractionEnabled = true
        self.thumbnailImageView.addGestureRecognizer(thumbnailImageTapGesture)
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
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    @objc func handleUploadButtonTapped() {
        let recordViewController = RecordViewController()
        recordViewController.isHeroEnabled = true
        self.navigationController?.hero.navigationAnimationType = .fade
        self.navigationController?.pushViewController(recordViewController, animated: true)
    }
}
