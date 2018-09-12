//
//  ViewController.swift
//  Magpie
//
//  Created by eraydiler on 09/10/2018.
//  Copyright (c) 2018 eraydiler. All rights reserved.
//

import UIKit
import Magpie

class ViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    
    private let magpie = Magpie()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func didTapReposButton(_ sender: UIButton) {
        
        fetchRepos()
    }
    
    private func fetchRepos() {
        guard let username = usernameField.text, !username.isEmpty else {
            
            return
        }
        
        fetch(withUsername: username)
    }
    
    private func fetch(withUsername username: String) {
        let urlString = String(format: Path.repos.rawValue, username)
        
        guard let url = URL(string: urlString) else {
            
            return
        }
        
        let request = Request(url: url, method: HTTPMethod.get)
        
        magpie.send(
            request,
            onSuccess: { data in
                print(">>> RESPONSE: \(data)")
            },
            onFail: { error in
                print(">>> ERROR: \(error)")
            }
        )
    }
}
