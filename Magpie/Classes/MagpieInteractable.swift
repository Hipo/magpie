//
//  MagpieInteractable.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

protocol MagpieInteractable: class {
    func send<ObjectType>(_ request: Request<ObjectType>) -> TaskCancellable? where ObjectType: Mappable
    func upload<ObjectType>(_ request: Request<ObjectType>, withData data: Data) -> TaskCancellable? where ObjectType: Mappable
    func retry<ObjectType>(_ request: Request<ObjectType>) -> TaskCancellable? where ObjectType: Mappable
    func cancel<ObjectType>(_ request: Request<ObjectType>) where ObjectType: Mappable
}
