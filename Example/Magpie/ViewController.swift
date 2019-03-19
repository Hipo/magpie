//
//  ViewController.swift
//  Magpie
//
//  Created by eraydiler on 09/10/2018.
//  Copyright (c) 2018 eraydiler. All rights reserved.
//

import UIKit
import Magpie
import enum Magpie.Error

class ViewController: UIViewController {
    private lazy var usernameField = UITextField()
    private lazy var reposButton = UIButton()
    
    // MARK: Variables: API
    private var request: EndpointInteractable?
    private let api: MOMAPI
    
    // MARK: Initialization
    init(api: MOMAPI) {
        self.api = api
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setupUsernameField()
        setupReposButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        request?.invalidate()
    }
    
    // MARK: Setup
    
    private func setupUsernameField() {
        usernameField.placeholder = "Github Username"
        usernameField.textAlignment = .center
        usernameField.borderStyle = .roundedRect
        usernameField.autocapitalizationType = .none
        
        setupUsernameFieldLayout()
    }
    
    private func setupReposButton() {
        reposButton.setTitle("Github Repos", for: .normal)
        reposButton.setTitleColor(UIColor.blue, for: .normal)
        reposButton.setTitleColor(UIColor.blue.withAlphaComponent(0.5), for: .highlighted)
        reposButton.addTarget(self, action: #selector(fetchGithubRepos), for: .touchUpInside)
        
        setupReposButtonLayout()
    }
    
    // MARK: Layout setup
    
    private func setupUsernameFieldLayout() {
        self.view.addSubview(usernameField)
        
        usernameField.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            usernameField.topAnchor.constraint(
                equalTo: self.view.topAnchor,
                constant: 60
            ),
            usernameField.leadingAnchor.constraint(
                equalTo: self.view.leadingAnchor,
                constant: 20
            ),
            usernameField.trailingAnchor.constraint(
                equalTo: self.view.trailingAnchor,
                constant: -20
            )
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func setupReposButtonLayout() {
        self.view.addSubview(reposButton)
        
        reposButton.translatesAutoresizingMaskIntoConstraints = false
        
        let constraints = [
            reposButton.topAnchor.constraint(
                equalTo: usernameField.bottomAnchor,
                constant: 20
            ),
            reposButton.centerXAnchor.constraint(
                equalTo: self.view.centerXAnchor
            )
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: Actions
    
    @objc func fetchGithubRepos() {
        for _ in 0..<5 {
            api.authenticate(with: "salih@hipolabs.com", password: "hipolabs") { [weak self] (response) in
                switch response {
                case .success(let user):
                    print("\(user)")
                case .failure(let error):
                    self?.handle(error)
                }
            }
        }
    }
    
    func handle(_ error: Error) {
        print("\(error.localizedDescription)")
    }
}

