//
//  URLSessionTask+Extensions.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 23.04.2019.
//

import Foundation

extension URLSessionTask {
    var isWaitingForResponse: Bool {
        return state == .running || state == .suspended
    }
}
