//
//  Response.swift
//  Pods
//
//  Created by Eray on 19.09.2018.
//

import UIKit

public enum Response<Object, Error> {
    case success(Object)
    case failed(Error)
}
