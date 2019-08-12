//
//  URLResponseHandler.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 12.08.2019.
//

import Foundation

protocol URLResponseHandler {
    func awake(with response: Response)
}
