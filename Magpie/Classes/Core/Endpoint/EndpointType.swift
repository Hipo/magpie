//
//  EndpointType.swift
//  Magpie
//
//  Created by Karasuluoglu on 18.12.2019.
//

import Foundation

public enum EndpointType {
    case data
    case upload(Source)
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

extension EndpointType {
    public enum Source {
        case data(Data)
        case file(URL)
    }
}

extension EndpointType: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .data:
            return "data"
        case .upload(let src):
            return "upload \(src.debugDescription)"
        case .multipart(let form):
            return "multipart\n\(form.debugDescription)"
        }
    }
}

extension EndpointType.Source: Printable {
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .data:
            return "data"
        case .file(let url):
            return "file at \(url.absoluteString)"
        }
    }
}
