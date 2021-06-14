// Copyright © 2020 hipolabs. All rights reserved.

import Alamofire
import Foundation
import MagpieCore

/**
 The conformance `MultipartFormData` protocol by `Alamofire.MultipartFormData`type.
 The built-in support of handling multipart form-data requests in Alamofire can be enabled easily
 for the library. The built-in structure in the library is implemented in parallel to the solution
 in `Alamofire`.
 */

/// <mark>
/// **MultipartFormData**
extension Alamofire.MultipartFormData: MagpieCore.MultipartFormData { }
