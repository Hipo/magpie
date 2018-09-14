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
    // MARK: Variables:API
    private var request: RequestOperatable?
    private let api: MomentAPI
    
    // MARK: Initialization
    init(api: MomentAPI) {
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
        
        loadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        request?.cancel()
    }
}

// MARK: Data
private extension ViewController {
    func loadData() {
        request = api.authenticate(withEmail: "salih@hipolabs.com", password: "hipolabs")
    }
}
