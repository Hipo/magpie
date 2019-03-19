//
//  RequestCancellable.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

public protocol TaskCancellable: AnyObject {
    func cancel()
}
