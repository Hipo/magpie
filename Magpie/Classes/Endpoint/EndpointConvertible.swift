//
//  EndpointConvertible.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 27.12.2018.
//

import Foundation

public protocol EndpointConvertible: AnyObject {
    associatedtype ObjectType where ObjectType: Mappable
    typealias RequestRef = Request<ObjectType>
    
    var request: RequestRef { get }
}
