import Combine
import Foundation

public enum DirectoryPath {
    case derivedData
    case xcode
    case test
}

public enum DirectoryError: Error {
    case invalidPath
    case failToMonitorPath
}

public final class Directory {
    private let fileManager = FileManager.default
    private var fileMonitor: DispatchSourceFileSystemObject?

    public init() { }

    deinit {
        stopMonitoring()
        fileMonitor = nil
    }

    public func fileExists(at directory: DirectoryPath) -> Bool {
        guard let directoryPath = directory.directoryPath else {
            return false
        }
        return fileManager.fileExists(atPath: directoryPath)
    }

    public func deleteDirectory(at directory: DirectoryPath) -> AnyPublisher<Bool, Error> {
        guard let directoryPath = directory.directoryPath, fileManager.fileExists(atPath: directoryPath) else {
            return Fail(error: DirectoryError.invalidPath).eraseToAnyPublisher()
        }

        do {
            try fileManager.removeItem(atPath: directoryPath)
            print(
                "--- DELETED --- : ", directoryPath,
                "\n--- EXISTS --- :", fileManager.fileExists(atPath: directoryPath).description.uppercased()
            )

            return Just(true)
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

        fileMonitor = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: [.write, .delete], queue: DispatchQueue.global())

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

    func stopMonitoring() {
        fileMonitor?.cancel()
    }
}

private extension DirectoryPath {
    /// Directory specific path.
    private var path: String {
        switch self {
        case .derivedData:
            return "Library/Developer/Xcode/DerivedData"

        case .xcode:
            return "Library/Developer/Xcode"

        case .test:
            return "Library/Developer/Xcode/Test"
        }
    }

    var directoryPath: String? {
        let fileManager = FileManager.default
        // Get root user directory
        guard let libraryDirectory = fileManager.urls(for: .userDirectory, in: .localDomainMask).first else {
            return nil
        }

        let username = NSUserName()
        let derivedDataPath = libraryDirectory
            .appendingPathComponent("\(username)/\(path)")

        print(
            "--- PATH --- : ", derivedDataPath.path(),
            "\n--- EXISTS --- :", fileManager.fileExists(atPath: derivedDataPath.path())
                .description
                .uppercased()
        )

        return derivedDataPath.path()
    }
}
