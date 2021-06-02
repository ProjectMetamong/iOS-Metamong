//
//  ResultViewController.swift
//  Metamong
//
//  Created by Seunghun Yang on 2021/06/01.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class ResultViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: ResultViewModel? = nil
    var disposeBag: DisposeBag = DisposeBag()
    
    let scoreLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 60, weight: .bold)
        return label
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = cornerRadius
        button.layer.masksToBounds = true
        button.backgroundColor = buttonColor.getUIColor
        button.setTitle("돌아가기", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .heavy)
        button.addTarget(self, action: #selector(self.handleConfirmButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - LifeCycles

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureUI()
        self.bindUI()
    }
    
    // MARK: - Helpers
    
    func configureUI() {
        self.view.backgroundColor = backgroundColor.getUIColor
        
        self.view.addSubview(self.scoreLabel)
        self.view.addSubview(self.confirmButton)
        
        self.scoreLabel.snp.makeConstraints {
            $0.centerX.equalTo(self.view.snp.centerX)
            $0.top.equalTo(self.view.snp.topMargin).offset(30)
        }
        
        self.confirmButton.snp.makeConstraints {
            $0.bottom.equalTo(self.view.snp.bottom).offset(-30)
            $0.left.equalTo(self.view.snp.left).offset(15)
            $0.right.equalTo(self.view.snp.right).offset(-15)
            $0.height.equalTo(50)
        }
    }
    
    func bindUI() {
        guard let viewModel = self.viewModel else { return }
        viewModel.score
            .filter { $0 != nil }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { score in
                self.scoreLabel.text = "\(score!)점"
            })
            .disposed(by: self.disposeBag)
    }
    
    // MARK: - Actions
    
    @objc func handleConfirmButtonTapped() {
        self.navigationController?.popToViewController(ofClass: DetailViewController.self, animated: true)
    }
}

// MARK: - Preview

#if DEBUG

import SwiftUI

struct VCRepresentable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    }
    
    @available(iOS 13.0.0, *)
    func makeUIViewController(context: Context) -> some UIViewController {
        let vc = ResultViewController()
        vc.viewModel = ResultViewModel(score: 88)
        
        return vc
    }
}

@available(iOS 13.0, *)
struct VCRepresentablePreview: PreviewProvider {
    static var previews: some View {
        VCRepresentable()
            .preferredColorScheme(.light)
            .previewDevice("iPhone 11")
    }
}

#endif
