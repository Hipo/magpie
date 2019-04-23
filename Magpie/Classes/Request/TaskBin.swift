//
//  TaskBin.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 23.04.2019.
//

import Foundation

struct TaskBin {
    private typealias Bin = [String: [URLSessionTask]]

    var numberOfTasks: Int {
        return binContainer.value.count
    }

    /// <note>
    /// AtomicVar is for preventing race-conditions.
    private var binContainer = AtomicVar<Bin>(value: [:])
}

extension TaskBin {
    typealias Endpoint = RequestConvertible & EndpointInteractable

    func save(_ task: TaskCancellable, for endpoint: Endpoint) {
        save(task, for: endpoint.path)
    }

    func removeTask(for endpoint: Endpoint) {
        if let task = endpoint.task {
            remove(task, for: endpoint.path)
        }
    }

    func cancelAndRemoveTask(for endpoint: Endpoint) {
        if let task = endpoint.task {
            cancelAndRemove(task, for: endpoint.path)
        }
    }
}

extension TaskBin {
    func save(_ task: TaskCancellable, for path: Path) {
        guard let urlSessionTask = task.underlyingTask else {
            return
        }
        binContainer.mutate { bin in
            if !urlSessionTask.isWaitingForResponse {
                return
            }

            let key = makeKey(path)

            guard var urlSessionTasks = bin[key] else {
                bin[key] = [urlSessionTask]
                return
            }
            urlSessionTasks.append(urlSessionTask)
            bin[key] = urlSessionTasks
        }
    }

    func remove(_ task: TaskCancellable, for path: Path) {
        remove(task, for: path, afterCancellation: false)
    }

    func cancelAndRemove(_ task: TaskCancellable, for path: Path) {
        remove(task, for: path, afterCancellation: true)
    }

    private func remove(_ task: TaskCancellable, for path: Path, afterCancellation: Bool) {
        guard let urlSessionTask = task.underlyingTask else {
            return
        }

        if afterCancellation {
            urlSessionTask.cancel()
        }
        binContainer.mutate { bin in
            let key = makeKey(path)

            guard var urlSessionTasks = bin[key] else {
                return
            }
            urlSessionTasks.removeAll { $0 == urlSessionTask }

            if urlSessionTasks.isEmpty {
                bin[key] = nil
                return
            }
            bin[key] = urlSessionTasks
        }
    }

    func removeAll(for path: Path) {
        removeAll(for: path, afterCancellation: false)
    }

    func cancelAndRemoveAll(for path: Path) {
        removeAll(for: path, afterCancellation: true)
    }

    private func removeAll(for path: Path, afterCancellation: Bool) {
        binContainer.mutate { bin in
            let key = makeKey(path)

            if afterCancellation {
                let urlSessionTasks = bin[key]
                urlSessionTasks?.forEach { $0.cancel() }
            }
            bin[key] = nil
        }
    }

    func removeAll(relativeTo path: Path) {
        removeAll(relativeTo: path, afterCancellation: false)
    }

    func cancelAndRemoveAll(relativeTo path: Path) {
        removeAll(relativeTo: path, afterCancellation: true)
    }

    private func removeAll(relativeTo path: Path, afterCancellation: Bool) {
        binContainer.mutate { bin in
            let relativeKey = makeKey(path)

            for elem in bin where elem.key.contains(relativeKey) {
                if afterCancellation {
                    elem.value.forEach { $0.cancel() }
                }
                bin[elem.key] = nil
            }
        }
    }

    func removeAll() {
        removeAll(afterCancellation: false)
    }

    func cancelAndRemoveAll() {
        removeAll(afterCancellation: true)
    }

    private func removeAll(afterCancellation: Bool) {
        binContainer.mutate { bin in
            if afterCancellation {
                bin.forEach { $1.forEach { $0.cancel() } }
            }
            bin.removeAll()
        }
    }

    private func makeKey(_ path: Path) -> String {
        return path.value
    }
}

extension TaskBin: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        let elementDescriptions = binContainer.value.map { elem -> String in
            let taskDescriptions = elem.value.map { $0.description }
            return "\(elem.key):[\n\t\t\(taskDescriptions.joined(separator: ",\n\t\t"))\n]"
        }
        return "{\n\t\(elementDescriptions.joined(separator: ",\n\t"))\n}"
    }

    var debugDescription: String {
        let elementDescriptions = binContainer.value.map { elem -> String in
            let taskDescriptions = elem.value.map { $0.debugDescription }
            return "\(elem.key):[\n\t\t\(taskDescriptions.joined(separator: ",\n\t\t"))\n]"
        }
        return "{\n\t\(elementDescriptions.joined(separator: ",\n\t"))\n}"
    }
}

