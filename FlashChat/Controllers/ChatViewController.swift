//
//  ChatViewController.swift
//  FlashChat
//
//  Created by Сазонов Станислав on 05.11.2023.
//

import UIKit
import Firebase

final class ChatViewController: UIViewController {
    
    // MARK: - UI
    
    private let tableView = UITableView()
    
    private lazy var containerView: UIView = {
        let element = UIView()
        element.backgroundColor = UIColor(named: K.BrandColors.purple)
        return element
    }()
    
    private lazy var messageTextField: UITextField = {
        let element = UITextField()
        element.backgroundColor = .white
        element.borderStyle = .roundedRect
        element.placeholder = K.enterMessagePlaceholder
        element.textColor = UIColor(named: K.BrandColors.purple)
        element.tintColor = UIColor(named: K.BrandColors.purple)
        return element
    }()
    
    private lazy var enterButton: UIButton = {
        let element = UIButton(type: .system)
        element.setImage(UIImage(systemName: K.enterButtonImageName), for: .normal)
        return element
    }()
    
    private lazy var logOut = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutTap))
    
    // MARK: - Private Properties
    
    private var messages: [Message] = []
    private let db = Firestore.firestore()
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegates()
        setViews()
        setupConstraints()
        loadMessages()
    }
    
    // MARK: - Set Views
    
    private func setViews() {
        view.backgroundColor = UIColor(named: K.BrandColors.purple)
        title = K.appName
        navigationController?.navigationBar.barTintColor = UIColor(named: K.BrandColors.blue)
        
        tableView.backgroundColor = .white
        tableView.register(MessageCell.self, forCellReuseIdentifier: K.cellIdentifier)
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        view.addSubview(containerView)
        containerView.addSubview(messageTextField)
        containerView.addSubview(enterButton)
        
        enterButton.addTarget(self, action: #selector(tapEnterButton), for: .touchUpInside)
        
        logOut.tintColor = .orange
        navigationItem.rightBarButtonItem = logOut
    }
    
    private func setDelegates() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func loadMessages() {
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { [weak self] quarySnapshot, error in
                
                guard let self = self else { return }
                self.messages = []
                
                if let e = error {
                    print("There was an issue retrieving data from Firestore. \(e)")
                } else {
                    guard let snapshotDocuments = quarySnapshot?.documents else { return }
                    
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        guard let sender = data[K.FStore.senderField] as? String,
                              let messageBody = data[K.FStore.bodyField] as? String else { return }
                        self.messages.append(Message(sender: sender, body: messageBody))
                        
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                            self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
    }
    // MARK: - Actions
    
    @objc private func tapEnterButton() {
        guard let messageBody = messageTextField.text,
              let messageSender = Auth.auth().currentUser?.email else { return }
        
        db.collection(K.FStore.collectionName).addDocument(data: [
            K.FStore.senderField: messageSender,
            K.FStore.bodyField: messageBody,
            K.FStore.dateField: Date().timeIntervalSince1970
        ]) { error in
            if let e = error {
                print("There was an issue saving data to firestore, \(e)")
            } else {
                DispatchQueue.main.async {
                    self.messageTextField.text = ""
                }
            }
        }
        
    }
    
    @objc private func logoutTap() {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
}
// MARK: - UITableViewDataSource, UITableViewDelegate

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as? MessageCell else { return UITableViewCell() }
        
        let message = messages[indexPath.row]
        let sender: Sender = message.sender == Auth.auth().currentUser?.email ? .me : .you
        
        cell.configure(width: message, sender: sender)
        
        cell.selectionStyle = .none
        
        return cell
    }
    
    
}

// MARK: - Setup Constraints
extension ChatViewController {
    
    private func setupConstraints() {
        
        tableView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(view.safeAreaLayoutGuide)
        }
        
        containerView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(60)
            make.top.equalTo(tableView.snp.bottom)
        }
        
        messageTextField.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().offset(20)
        }
        
        enterButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(20)
            make.leading.equalTo(messageTextField.snp.trailing).offset(20)
            make.height.width.equalTo(40)
        }
    }
}
