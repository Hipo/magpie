//
//  MagpieOperatable.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 5.10.2018.
//

import Foundation

protocol MagpieOperatable: class {
    func send<ObjectType>(_ request: Request<ObjectType>) -> TaskCancellable?
    where ObjectType: Mappable

    func retry<ObjectType>(_ request: Request<ObjectType>) -> TaskCancellable?
    where ObjectType: Mappable

    func cancel<ObjectType>(_ request: Request<ObjectType>) where ObjectType: Mappable
}
