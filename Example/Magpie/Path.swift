//
//  Path.swift
//  Magpie_Example
//
//  Created by Eray on 12.09.2018.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import Foundation

enum Path: String {
    case repos = "https://api.github.com/users/%@/repos"
    
    var url: URL {
        return URL(string: self.rawValue)!
    }
}
