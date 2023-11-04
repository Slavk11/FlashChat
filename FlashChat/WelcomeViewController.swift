//
//  WelcomeViewController.swift
//  FlashChat
//
//  Created by Сазонов Станислав on 02.11.2023.
//

import UIKit
import SnapKit

class WelcomeViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var titleLabel: UILabel = {
        let element = UILabel()
        element.textColor = UIColor(named: K.BrandColors.blue)
        element.font = .systemFont(ofSize: 50, weight: .black)
        return element
    }()
    
    let registerButton = UIButton(
        titleColor: UIColor(named: K.BrandColors.blue),
        backgroundColor: UIColor(named:K.BrandColors.lightBlue)
    )
    
    let logInButton = UIButton(
        titleColor: .white,
        backgroundColor: .systemTeal
    )
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        setupConstraints()
        animationText()
    }
    
    // MARK: - Set Views
    
    private func setViews() {
        view.backgroundColor = .white
        navigationController?.navigationBar.tintColor = .systemYellow
        
        view.addSubview(titleLabel)
        view.addSubview(logInButton)
        view.addSubview(registerButton)
        
        titleLabel.text = K.appName
        registerButton.setTitle(K.registerName, for: .normal)
        logInButton.setTitle(K.logInName, for: .normal)
        
        registerButton.addTarget(self, action: #selector(buttonsTapped), for: .touchUpInside)
        logInButton.addTarget(self, action: #selector(buttonsTapped), for: .touchUpInside)
        
    }
    
    private func animationText() {
        titleLabel.text = ""
        let titleText = K.appName
        
        for letter in titleText.enumerated() {
            Timer.scheduledTimer(withTimeInterval: 0.1 * Double(letter.offset), repeats: false) { _ in
                self.titleLabel.text! += String(letter.element)
            }
        }
    }
    
    @objc private func buttonsTapped(_ sender: UIButton) {
        let nextVC = RegisterViewController()
        
        if sender.currentTitle == K.registerName {
            nextVC.authorizationType = .register
        } else if sender.currentTitle == K.logInName {
            nextVC.authorizationType = .logIn
        }
        
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
}

// MARK: - Setup Constraints

extension WelcomeViewController {
    
    private func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        logInButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(K.Size.buttonSize)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        registerButton.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(K.Size.buttonSize)
            make.bottom.equalTo(logInButton.snp.top).offset(-K.Size.buttonOffset)
        }
    }
}

extension UIButton {
    convenience init(titleColor: UIColor?, backgroundColor: UIColor? = .clear) {
        self .init(type: .system)
        self.titleLabel?.font = .systemFont(ofSize: 30)
        self.setTitleColor(titleColor, for: .normal)
        self.backgroundColor = backgroundColor
    }
}
