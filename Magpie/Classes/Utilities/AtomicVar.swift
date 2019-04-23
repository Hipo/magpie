//
//  AtomicVar.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 23.04.2019.
//

/// <reference>
/// See https://www.objc.io/blog/2018/12/18/atomic-variables/

import Foundation

final class AtomicVar<Value> {
    private var underlyingValue: Value
    private let queue = DispatchQueue(label: "com.hipo.magpie.queue.atomic_vars")

    var value: Value {
        return queue.sync {
            self.underlyingValue
        }
    }

    init(value: Value) {
        self.underlyingValue = value
    }

    func mutate(_ transform: (inout Value) -> Void) {
        queue.sync {
            transform(&self.underlyingValue)
        }
    }
}
