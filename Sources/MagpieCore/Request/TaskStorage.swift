//
//  TaskStorage.swift
//  Magpie
//
//  Created by Salih Karasuluoglu on 4.04.2019.
//

import Foundation
import MacaroonUtils

struct TaskStorage {
    @Atomic(identifier: "table")
    private var table: [String: [TaskConvertible]] = [:]
}

extension TaskStorage {
    func add(_ task: TaskConvertible, for endpoint: Endpoint) {
        add(task, for: endpoint.request.path.encoded())
    }

    func add(_ task: TaskConvertible, for path: String) {
        $table.mutate { mTable in
            if !task.inProgress { return }

            if var currentTasks = mTable[path] {
                currentTasks.append(task)
                mTable[path] = currentTasks
            } else {
                mTable[path] = [task]
            }
        }
    }
}

extension TaskStorage {
    func delete(for endpoint: Endpoint) {
        if let task = endpoint.task {
            delete(task, with: endpoint.request.path.encoded())
        }
    }

    func cancelAndDelete(for endpoint: Endpoint) {
        if let task = endpoint.task {
            cancelAndDelete(task, with: endpoint.request.path.encoded())
        }
    }

    func delete(_ task: TaskConvertible, with path: String) {
        delete(task, with: path, afterCancellation: false)
    }

    func cancelAndDelete(_ task: TaskConvertible, with path: String) {
        delete(task, with: path, afterCancellation: true)
    }

    func deleteAll(with path: String) {
        deleteAll(with: path, afterCancellation: false)
    }

    func cancelAndDeleteAll(with path: String) {
        deleteAll(with: path, afterCancellation: true)
    }

    func deleteAll(relativeTo path: String) {
        deleteAll(relativeTo: path, afterCancellation: false)
    }

    func cancelAndDeleteAll(relativeTo path: String) {
        deleteAll(relativeTo: path, afterCancellation: true)
    }

    func deleteAll() {
        deleteAll(afterCancellation: false)
    }

    func cancelAndDeleteAll() {
        deleteAll(afterCancellation: true)
    }
}

extension TaskStorage {
    private func delete(_ task: TaskConvertible, with path: String, afterCancellation: Bool) {
        if afterCancellation {
            task.cancelNow()
        }
        $table.mutate { mTable in
            guard var currentTasks = mTable[path] else { return }

            currentTasks.removeAll {
                $0.taskIdentifier == task.taskIdentifier
            }

            if currentTasks.isEmpty {
                mTable[path] = nil
            } else {
                mTable[path] = currentTasks
            }
        }
    }

    private func deleteAll(with path: String, afterCancellation: Bool) {
        $table.mutate { mTable in
            if afterCancellation {
                mTable[path]?.forEach { $0.cancelNow() }
            }
            mTable[path] = nil
        }
    }

    private func deleteAll(relativeTo path: String, afterCancellation: Bool) {
        $table.mutate { mTable in
            for item in mTable where item.key.contains(path) {
                if afterCancellation {
                    item.value.forEach { $0.cancelNow() }
                }
                mTable[item.key] = nil
            }
        }
    }

    private func deleteAll(afterCancellation: Bool) {
        $table.mutate { mTable in
            if afterCancellation {
                mTable.forEach { $1.forEach { $0.cancelNow() } }
            }
            mTable.removeAll()
        }
    }
}

extension TaskStorage: Printable {
    /// <mark> CustomStringConvertible
    var description: String {
        return """
        {
          \(table
            .map({ "\($0.key):[\($0.value.map({ $0.description }).joined(separator: ", "))]" })
            .joined(separator: "\n  ")
          )
        }
        """
    }
    /// <mark> CustomDebugStringConvertible
    var debugDescription: String {
        return """
        {
          \(table
            .map({ "\($0.key):[\n\t\($0.value.map({ $0.debugDescription }).joined(separator: ",\n\t"))]" })
            .joined(separator: "\n  ")
          )
        }
        """
    }
}
