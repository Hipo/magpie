//
//  Method.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 21.10.2018.
//

import Foundation
import MacaroonUtils

public enum Method: String, Printable {
    case get = "GET"
    case head = "HEAD"
    case delete = "DELETE"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
}
