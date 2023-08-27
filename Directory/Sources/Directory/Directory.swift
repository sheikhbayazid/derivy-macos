//
//  Directory.swift
//  Directory
//
//  Created by Sheikh Bayazid on 2023-08-26.
//  Copyright © 2023 Sheikh Bayazid. All rights reserved.
//

import Combine
import Foundation

public final class Directory {
    private let fileManager = FileManager.default
    private var fileMonitor: DispatchSourceFileSystemObject?

    public init() { }

    public func fileExists(at directory: DirectoryPath) -> Bool {
        guard let directoryPath = directory.directoryPath else {
            return false
        }
        return fileManager.fileExists(atPath: directoryPath)
    }

    public func deleteDirectory(at directory: DirectoryPath) -> AnyPublisher<Void, Error> {
        guard let directoryPath = directory.directoryPath, fileExists(at: directory) else {
            return Fail(error: DirectoryError.invalidPath).eraseToAnyPublisher()
        }

        do {
            try fileManager.removeItem(atPath: directoryPath)
            print(
                "--- DELETED --- : ", directoryPath,
                "\n--- EXISTS --- :", fileExists(at: directory).description.uppercased()
            )

            return Just(Void())
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    public func startObserving(atPath directory: DirectoryPath) -> AnyPublisher<Void, Error> {
        let publisher: PassthroughSubject<Void, Error> = .init()

        guard let directoryPath = directory.directoryPath else {
            return Fail(error: DirectoryError.invalidPath).eraseToAnyPublisher()
        }

        let fileDescriptor = open(directoryPath, O_EVTONLY)
        guard fileDescriptor != -1 else {
            return Fail(error: DirectoryError.failToMonitorPath).eraseToAnyPublisher()
        }

        fileMonitor = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fileDescriptor,
            eventMask: [.write, .delete],
            queue: DispatchQueue.global()
        )

        fileMonitor?.setEventHandler {
            publisher.send(Void())
        }

        fileMonitor?.setCancelHandler { [weak self] in
            close(fileDescriptor)
            self?.fileMonitor = nil
        }

        fileMonitor?.resume()
        return publisher.eraseToAnyPublisher()
    }

    public func stopMonitoring() {
        fileMonitor?.cancel()
    }
}
