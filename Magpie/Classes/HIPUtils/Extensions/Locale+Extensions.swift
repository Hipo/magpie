//
//  Locale+Extensions.swift
//  Pods
//
//  Created by Salih Karasuluoglu on 28.01.2021.
//

import Foundation

extension Locale {
    static var preferred: Locale {
        guard let identifier = Bundle.main.preferredLocalizations.first else {
            return .current
        }

        return Locale(identifier: identifier)
    }
}
