//
//  Array+Extensions.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 26.11.2018.
//

import Foundation

extension Array {
    mutating func removeFirst(where predicate: (Element) -> Bool) {
        guard let idx = firstIndex(where: predicate) else {
            return
        }
        remove(at: idx)
    }
}

extension Array where Element == URLQueryItem {
    func encoded() -> String? {        
        var components = URLComponents()
        components.queryItems = self
        return components.query
    }
}
