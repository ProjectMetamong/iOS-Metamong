//
//  ExerciseUploadViewController.swift
//  PoC UIKit
//
//  Created by Seunghun Yang on 2021/05/04.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import RxGesture
import JGProgressHUD

class UploadViewController: UIViewController {
    // MARK: - Properties

    private let viewModel: UploadViewModel = UploadViewModel()
    private let disposeBag: DisposeBag = DisposeBag()
    
    lazy var thumbnailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .systemGray3
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = cornerRadius
        imageView.clipsToBounds = false
        imageView.isUserInteractionEnabled = true
        return imageView
    }()

    lazy var titleLabelOverThumbnail: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.textColor = .white
        label.text = "테스트"
        return label
    }()
    
    lazy var difficultyLabelOverThumbnail: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    lazy var timeLabelOverThumbnail: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    lazy var creatorLabelOverThumbnail: UILabel = {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor.getUIColor
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    lazy var imagePicker: UIImagePickerController = {
        let picker: UIImagePickerController = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        return picker
    }()
    
    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        textField.placeholder = "타이틀"
        return textField
    }()
    
    lazy var creatorTextField: UITextField = {
        let textField = UITextField()
        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.placeholder = "제작자"
        return textField
    }()
    
    lazy var difficultyTextField: PickerTextField = {
        let textField = PickerTextField()
        textField.inputView = self.difficultyPicker
        textField.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        textField.textColor = .black
        textField.textAlignment = .center
        textField.backgroundColor = .clear
        textField.placeholder = "난이도 선택"
        textField.borderStyle = .roundedRect
        return textField
    }()

    lazy var difficultyPicker : UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        textView.backgroundColor = .clear
        textView.addSubview(self.descriptionTextViewPlaceholderTextView)
        textView.delegate = self
        return textView
    }()
    
    lazy var descriptionTextViewPlaceholderTextView: UILabel = {
        let label = UILabel()
        label.text = "운동에 대한 설명을 작성해주세요."
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 5, y: 10)
        label.textColor = UIColor.lightGray
        return label
    }()
    
    lazy var recordButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.backgroundColor = recordIndicatingColor.getUIColor
        button.setTitle("촬영", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleRecordButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var uploadButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = buttonColor.getUIColor
        button.setTitle("업로드", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleUploadButtonTapped), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var uploadProgressHud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .dark)
        hud.vibrancyEnabled = true
        hud.indicatorView = JGProgressHUDPieIndicatorView()
        return hud
    }()
    
    // MARK: - Lifecycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.bindUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.navigationController?.isHeroEnabled = true
        
        self.view.addSubview(self.thumbnailImageView)
        self.view.addSubview(self.titleLabelOverThumbnail)
        self.view.addSubview(self.difficultyLabelOverThumbnail)
        self.view.addSubview(self.timeLabelOverThumbnail)
        self.view.addSubview(self.creatorLabelOverThumbnail)
        self.view.addSubview(self.titleTextField)
        self.view.addSubview(self.creatorTextField)
        self.view.addSubview(self.difficultyTextField)
        self.view.addSubview(self.recordButton)
        self.view.addSubview(self.descriptionTextView)
        self.view.addSubview(self.uploadButton)
        
        self.view.bringSubviewToFront(self.titleLabelOverThumbnail)
        self.view.bringSubviewToFront(self.difficultyLabelOverThumbnail)
        self.view.bringSubviewToFront(self.timeLabelOverThumbnail)
        self.view.bringSubviewToFront(self.creatorLabelOverThumbnail)
        
        self.thumbnailImageView.snp.makeConstraints {
            let width = (self.view.frame.width - 45) / 2
            $0.top.equalTo(self.view.snp.topMargin).offset(15)
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.width.equalTo(width)
            $0.height.equalTo(width)
        }
        
        self.difficultyLabelOverThumbnail.snp.makeConstraints {
            $0.bottom.equalTo(self.thumbnailImageView.snp.bottom).offset(-15)
            $0.right.equalTo(self.thumbnailImageView.snp.right).offset(-12)
        }
        
        self.titleLabelOverThumbnail.snp.makeConstraints {
            $0.bottom.equalTo(self.thumbnailImageView.snp.bottom).offset(-35.5)
            $0.right.equalTo(self.thumbnailImageView.snp.right).offset(-12)
            $0.left.greaterThanOrEqualTo(self.thumbnailImageView.snp.left).offset(12)
        }
        
        self.timeLabelOverThumbnail.snp.makeConstraints {
            $0.top.equalTo(self.thumbnailImageView.snp.top).offset(12)
            $0.left.equalTo(self.thumbnailImageView.snp.left).offset(12)
        }
        
        self.titleTextField.snp.makeConstraints {
            $0.top.equalTo(self.view.snp.topMargin).offset(15)
            $0.left.equalTo(self.thumbnailImageView.snp.right).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
        }
        
        self.creatorLabelOverThumbnail.snp.makeConstraints {
            $0.bottom.equalTo(self.thumbnailImageView.snp.bottom).offset(-15)
            $0.left.equalTo(self.thumbnailImageView.snp.left).offset(12)
            $0.right.lessThanOrEqualTo(self.thumbnailImageView.snp.right).offset(-50)
        }
        
        self.creatorTextField.snp.makeConstraints {
            $0.top.equalTo(self.titleTextField.snp.bottom).offset(15)
            $0.left.equalTo(self.thumbnailImageView.snp.right).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
        }
        
        self.difficultyTextField.snp.makeConstraints {
            $0.top.equalTo(self.creatorTextField.snp.bottom).offset(8)
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.left.equalTo(self.thumbnailImageView.snp.right).offset(15)
        }
        
        self.recordButton.snp.makeConstraints {
            $0.top.equalTo(self.difficultyTextField.snp.bottom).offset(8)
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.left.equalTo(self.thumbnailImageView.snp.right).offset(15)
        }
        
        self.descriptionTextView.snp.makeConstraints {
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
    }
    
    func bindUI() {
        self.view.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.view.endEditing(true)
            })
            .disposed(by: self.disposeBag)
        
        self.thumbnailImageView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { _ in
                self.present(self.imagePicker, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        self.thumbnailImageView.rx.observe(UIImage.self, #keyPath(UIImageView.image))
            .bind(to: self.viewModel.thumbnailImage)
            .disposed(by: self.disposeBag)
        
        self.titleTextField.rx.text
            .orEmpty
            .bind(to: self.viewModel.title)
            .disposed(by: self.disposeBag)
        
        self.creatorTextField.rx.text
            .orEmpty
            .bind(to: self.viewModel.creator)
            .disposed(by: self.disposeBag)
    
        self.difficultyTextField.rx.text
            .orEmpty
            .bind(to: self.viewModel.difficulty)
            .disposed(by: self.disposeBag)
        
        self.descriptionTextView.rx.text
            .orEmpty
            .bind(to: self.viewModel.description)
            .disposed(by: self.disposeBag)
        
        self.titleTextField.rx.text
            .orEmpty
            .subscribe(onNext: {
                self.titleLabelOverThumbnail.text = $0
            })
            .disposed(by: self.disposeBag)
        
        self.creatorTextField.rx.text
            .orEmpty
            .subscribe(onNext: {
                self.creatorLabelOverThumbnail.text = $0
            })
            .disposed(by: self.disposeBag)
        
        self.difficultyTextField.rx.text
            .orEmpty
            .subscribe(onNext: {
                self.difficultyLabelOverThumbnail.text = $0
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.length
            .filter({
                $0 != nil
            })
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.recordButton.setTitle($0?.msToTimeString(forStopWatch: true), for: .normal)
                self.timeLabelOverThumbnail.text = $0?.msToTimeString()
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.isUploadButtonActive
            .bind(to: self.uploadButton.rx.isEnabled)
            .disposed(by: self.disposeBag)
        
        self.viewModel.isUploadButtonActive
            .map { $0 ? 1 : 0.5 }
            .bind(to: self.uploadButton.rx.alpha)
            .disposed(by: self.disposeBag)
        
        self.viewModel.progress
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.uploadProgressHud.progress = Float($0)
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.progress
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.uploadProgressHud.progress = Float($0)
                self.uploadProgressHud.detailTextLabel.text = String(format: "%.2f", ($0 * 100)) + "%"
            })
            .disposed(by: self.disposeBag)
        
        self.viewModel.progressHudDescription
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.uploadProgressHud.textLabel.text = $0
            })
            .disposed(by: self.disposeBag)
    }
    
    func showHud() {
        self.uploadProgressHud.indicatorView = JGProgressHUDPieIndicatorView()
        self.uploadProgressHud.show(in: self.view)
    }
    
    
    func dismissHud() {
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            UIView.animate(withDuration: 0.1, animations: {
                self.uploadProgressHud.textLabel.text = "업로드 완료!"
                self.uploadProgressHud.detailTextLabel.text = nil
                self.uploadProgressHud.indicatorView = JGProgressHUDSuccessIndicatorView()
            })
            self.uploadProgressHud.dismiss(afterDelay: 1.0)
        }
    }
    
    // MARK: - Actions
    
    @objc func handleRecordButtonTapped() {
        let recordViewController = RecordViewController()
        recordViewController.isHeroEnabled = true
        recordViewController.delegate = self
        self.navigationController?.hero.navigationAnimationType = .fade
        self.navigationController?.pushViewController(recordViewController, animated: true)
    }
    
    @objc func handleUploadButtonTapped() {
        self.showHud()
        self.viewModel.upload(completion: self.dismissHud)
    }
    
    @objc func dismissPicker() {
        self.difficultyTextField.resignFirstResponder()
    }
}

// MARK: - UIImagePickerControllerDelegate

extension UploadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let image = info[UIImagePickerController.InfoKey.editedImage] as! UIImage
        self.thumbnailImageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension UploadViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        self.descriptionTextViewPlaceholderTextView.isHidden = !self.descriptionTextView.text.isEmpty
    }
}

// MARK: - UIPickerViewDelegate

extension UploadViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        return self.difficultyTextField.text = difficulties[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return difficulties[row]
    }
}


// MARK: - UIPickerViewDataSource

extension UploadViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return difficulties.count
    }
}

// MARK: - RecordViewControllerDelegate

extension UploadViewController: RecordViewControllerDelegate {
    func didFisnishedRecording(length: Int) {
        self.viewModel.length.accept(length)
    }
}

// MARK: - Preview

#if DEBUG

import SwiftUI

struct UploadViewControllerRepresentable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = UploadViewController()
        
        return vc
    }
}

@available(iOS 13.0, *)
struct UploadViewControllerRepresentablePreview: PreviewProvider {
    static var previews: some View {
        UploadViewControllerRepresentable()
            .preferredColorScheme(.light)
            .previewDevice("iPhone 11")
    }
}

#endif
