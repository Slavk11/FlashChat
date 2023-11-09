//
//  RegisterViewController.swift
//  FlashChat
//
//  Created by Сазонов Станислав on 03.11.2023.
//

import UIKit
import SnapKit
import Firebase

enum AuthorizationType: String {
    case register = "Register"
    case logIn = "Log In"
}

final class RegisterViewController: UIViewController {
    
    // MARK: - UI
    
    private lazy var mainStackView: UIStackView = {
        let element = UIStackView()
        element.axis = .vertical
        element.spacing = 8
        
        return element
    }()
    
    let emailTextField = UITextField(
        placeholder: K.emailName,
        color: UIColor(named: K.BrandColors.blue)
    )
    
    private lazy var imageView: UIImageView = {
        let element = UIImageView()
        element.isUserInteractionEnabled = true
        element.image = UIImage(named: K.textfieldImageName)
        return element
    }()
    
    private let passwordTextField = UITextField(
        placeholder: K.passwordName,
        color: .black
    )
    
    let registerButton = UIButton(titleColor: UIColor(named: K.BrandColors.blue))
    
    // MARK: - Public Properties
    
    public var authorizationType: AuthorizationType?
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViews()
        setupConstraints()
        
    }
    
    // MARK: - Set Views
    
    private func setViews() {
        switch authorizationType {
        case .register:
            view.backgroundColor = UIColor(named: K.BrandColors.lightBlue)
            registerButton.setTitle(K.registerName, for: .normal)
            registerButton.setTitleColor(UIColor(named: K.BrandColors.blue), for: .normal)
        case .logIn:
            view.backgroundColor = UIColor(named: K.BrandColors.blue)
            registerButton.setTitle(K.logInName, for: .normal)
            registerButton.setTitleColor(.white, for: .normal)
            
            emailTextField.text = "1@1.com"
            
        default: break
        }
        
        view.addSubview(mainStackView)
        mainStackView.addArrangedSubview(emailTextField)
        mainStackView.addArrangedSubview(imageView)
        imageView.addSubview(passwordTextField)
        mainStackView.addArrangedSubview(registerButton)
        
        emailTextField.makeShadow()
        passwordTextField.isSecureTextEntry = true
        
        registerButton.addTarget(self, action: #selector(buttonsTapped), for: .touchUpInside)
    }
    
    @objc private func buttonsTapped(_ sender: UIButton) {
        if sender.currentTitle == K.logInName {
            
            guard let email = emailTextField.text,
                  let password = passwordTextField.text else { return }
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
                guard let self = self else { return }
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    let chatVC = ChatViewController()
                    
                    navigationController?.pushViewController(chatVC, animated: true)
                }
                
            }
            
        } else {
            guard let email = emailTextField.text,
                  let password = passwordTextField.text else { return }
            
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let e = error {
                    print(e.localizedDescription)
                } else {
                    let chatVC = ChatViewController()
                    
                    self.navigationController?.pushViewController(chatVC, animated: true)
                }
            }
        }
    }
    
}

// MARK: - Setup Constraints

extension RegisterViewController {
    
    private func setupConstraints() {
        mainStackView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        emailTextField.snp.makeConstraints { make in
            make.height.equalTo(60)
            make.leading.trailing.equalTo(view).inset(36)
        }
        
        imageView.snp.makeConstraints { make in
            make.height.equalTo(137)
            make.leading.trailing.equalTo(view)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(30)
            make.bottom.equalToSuperview().offset(-62)
            make.leading.trailing.equalToSuperview().inset(48)
            make.height.equalTo(45)
        }
    }
}


