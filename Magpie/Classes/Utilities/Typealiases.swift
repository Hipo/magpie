//
//  Typealiases.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 26.03.2019.
//

import Foundation

public typealias FoundationError = Swift.Error
public typealias ResponseHandler = (Response) -> Void
public typealias JSONBodyPairValue = AnyEncodable
public typealias FormBodyPairValue = CustomStringConvertible

typealias JSON = [String: Any]
