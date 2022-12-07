// Copyright © 2022 hipolabs. All rights reserved.

import Foundation

public protocol FileModel: DownloadModel {
    var url: URL { get }
    var isFault: Bool { get }
}

extension FileModel {
    public var isFault: Bool {
        return !url.isFileURL
    }
}
