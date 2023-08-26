import Combine
import Foundation

public enum DirectoryPath {
    case derivedData
    case xcode
    case test
}

public enum DirectoryError: Error {
    case pathDoesNotExists
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
        guard let directoryPath = directory.directoryPath,
              fileManager.fileExists(atPath: directoryPath) else {
            return Fail(error: DirectoryError.pathDoesNotExists).eraseToAnyPublisher()
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

    public func startObserving(directory: DirectoryPath, completion: @escaping () -> Void) {
        guard let directoryPath = directory.directoryPath else {
                print("Invalid path")
                return
        }

        let fileDescriptor = open(directoryPath, O_EVTONLY)
        guard fileDescriptor != -1 else {
            print("Error opening directory for monitoring")
            return
        }

        fileMonitor = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: [.write, .delete], queue: DispatchQueue.global())

        fileMonitor?.setEventHandler {
            completion()
        }

        fileMonitor?.setCancelHandler { [weak self] in
            close(fileDescriptor)
            self?.fileMonitor = nil
        }

        fileMonitor?.resume()
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
