//
//  Data+Extensions.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 9.10.2018.
//

import Foundation

extension Data {
    func toJSON() throws -> Any {
        return try JSONSerialization.jsonObject(with: self)
    }
}
