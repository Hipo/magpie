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
}

extension EndpointType {
    public enum Source {
        case data(Data)
        case file(URL)
    }
}

extension EndpointType: Printable {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch self {
        case .data:
            return "data"
        case .upload(let src):
            return "upload \(src.description)"
        }
    }
    /// <mark> CustomDebugStringConvertible
    public var debugDescription: String {
        switch self {
        case .data:
            return "data"
        case .upload(let src):
            return "upload \(src.debugDescription)"
        }
    }
}

extension EndpointType.Source: Printable {
    /// <mark> CustomStringConvertible
    public var description: String {
        switch self {
        case .data:
            return "data"
        case .file:
            return "file"
        }
    }
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
