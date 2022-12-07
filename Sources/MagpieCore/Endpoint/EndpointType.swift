//
//  EndpointType.swift
//  Magpie
//
//  Created by Karasuluoglu on 18.12.2019.
//

import Foundation
import MacaroonUtils

public enum EndpointType {
    case data
    case download(DownloadDestination)
    case upload(UploadSource)
    case multipart(MultipartForm)
}

extension EndpointType {
    public var isData: Bool {
        switch self {
        case .data:
            return true
        default:
            return false
        }
    }
    public var isDownload: Bool {
        switch self {
        case .download:
            return true
        default:
            return false
        }
    }
    public var isUpload: Bool {
        switch self {
        case .upload:
            return true
        default:
            return false
        }
    }
    public var isMultipart: Bool {
        switch self {
        case .multipart:
            return true
        default:
            return false
        }
    }
}

extension EndpointType: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .data:
            return "data"
        case .download(let dest):
            return "download \(dest.debugDescription)"
        case .upload(let src):
            return "upload \(src.debugDescription)"
        case .multipart(let form):
            return "multipart\n\(form.debugDescription)"
        }
    }
}

extension EndpointType {
    public enum DownloadDestination {
        case file(URL)
    }

    public enum UploadSource {
        case data(Data)
        case file(URL)
    }
}

extension EndpointType.DownloadDestination: Printable {
    public var debugDescription: String {
        switch self {
        case .file(let url):
            return "destination: \(url.absoluteString)"
        }
    }
}

extension EndpointType.UploadSource: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .data:
            return "data"
        case .file(let url):
            return "source: \(url.absoluteString)"
        }
    }
}
