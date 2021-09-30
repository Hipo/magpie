// Copyright © 2021 hipolabs. All rights reserved.

import Foundation
import MacaroonUtils

public typealias APIModel = JSONModel & ResponseModel

public struct NoAPIModel: APIModel {
    public init() {}
}
