//
//  ResultHandler.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 2.04.2019.
//

import Foundation

protocol ResultHandler {
    var modelDecodingStrategy: ModelDecodingStrategy? { get set }
    var errorModelDecodingStrategy: ModelDecodingStrategy? { get set }

    func awake(with response: Response)
}
