//
//  RequestBin.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 30.11.2018.
//

import Foundation

struct RequestBin {
    fileprivate typealias Bin = [Path: [Element]]
    
    private var requests = Bin()
}

extension RequestBin {
    mutating func append(_ newRequest: Element) {
        guard var existingRequests = requests[newRequest.path] else {
            requests[newRequest.path] = [newRequest]
            return
        }
        
        existingRequests.append(newRequest)
        requests[newRequest.path] = existingRequests
    }
    
    mutating func remove(_ request: Element) {
        guard var existingRequests = requests[request.path] else {
            return
        }
        
        existingRequests.removeFirst { $0.task === request.task }
        
        if existingRequests.isEmpty {
            requests[request.path] = nil
            return
        }
        
        requests[request.path] = existingRequests
    }
    
    mutating func invalidateAndRemoveRequests(with path: Path) {
        guard let foundRequests = requests[path] else {
            return
        }
        
        for var request in foundRequests {
            request.invalidate()
        }
        requests[path] = nil
    }
    
    mutating func invalidateAndRemoveRequests(relativeTo path: Path) {
        for element in requests where element.key.contains(path) {
            for var request in element.value {
                request.invalidate()
            }
            requests[element.key] = nil
        }
    }
    
    mutating func invalidateAndRemoveAll() {
        for element in requests {
            for var request in element.value {
                request.invalidate()
            }
        }
        requests.removeAll()
    }
    
    subscript (path: Path) -> [Element] {
        return requests[path] ?? []
    }
}

extension RequestBin {
    struct InnerIndex {
        fileprivate let path: Bin.Index
        fileprivate let position: Bin.Value.Index
    }
}

extension RequestBin: Collection {
    typealias Index = InnerIndex
    typealias Element = RequestConvertible & EndpointInteractable
    
    var startIndex: Index {
        let binStartIndex = requests.startIndex
        var elementsStartIndex = Bin.Value().startIndex

        if !requests.isEmpty {
            elementsStartIndex = requests[binStartIndex].value.startIndex
        }

        return Index(
            path: binStartIndex,
            position: elementsStartIndex
        )
    }
    
    var endIndex: Index {
        let binEndIndex = requests.endIndex
        let elementsEndIndex = Bin.Value().endIndex
        
        return Index(
            path: binEndIndex,
            position: elementsEndIndex
        )
    }
    
    subscript (index: Index) -> Element {
        return requests[index.path].value[index.position]
    }

    func index(after i: Index) -> Index {
        let binIndex = i.path
        
        if binIndex >= requests.endIndex {
            return endIndex
        }
        
        let elements = requests[binIndex].value
        let nextElementIndex = elements.index(after: i.position)
        
        if nextElementIndex < elements.endIndex {
            return Index(
                path: binIndex,
                position: nextElementIndex
            )
        }
        
        let nextBinIndex = requests.index(after: binIndex)
        
        if nextBinIndex < requests.endIndex {
            let nextElementIndex = requests[nextBinIndex].value.startIndex
            return Index(
                path: nextBinIndex,
                position: nextElementIndex
            )
        }

        return endIndex
    }
}

extension RequestBin: CustomStringConvertible {
    var description: String {
        return requests.reduce("") { (result, element) -> String in
            let path = try? element.key.toString()
            return result + "\(path ?? "null"):\(element.value.count)\n"
        }
    }
}

extension RequestBin.Index: Comparable {
    static func == (
        lhs: RequestBin.Index,
        rhs: RequestBin.Index
    ) -> Bool {
        return lhs.path == rhs.path &&
               lhs.position == rhs.position
    }
    
    static func < (
        lhs: RequestBin.Index,
        rhs: RequestBin.Index
    ) -> Bool {
        if lhs.path < rhs.path {
            return true
        }
        return lhs.position < rhs.position
    }
}
