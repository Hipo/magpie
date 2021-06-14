//
//  TaskConvertible.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation
import MacaroonUtils

public protocol TaskConvertible: Printable {
    var taskIdentifier: Int { get }
    var inProgress: Bool { get }

    func cancelNow()
}
