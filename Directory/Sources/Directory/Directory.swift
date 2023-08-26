import Combine
import Foundation

public enum DirectoryPath {
    case derivedData
    case test
}

public enum DirectoryError: Error {
    case pathDoesNotExists
}

public final class Directory {
    private let fileManager = FileManager.default

    public init() { }

    public func fileExists(at directory: DirectoryPath) -> Bool {
        fileManager.fileExists(atPath: directory.path)
    }

    public func deleteDirectory(at directory: DirectoryPath) -> AnyPublisher<Bool, Error> {
        guard let directoryPath = getUserPathURL(directory)?.path(),
              fileManager.fileExists(atPath: directoryPath) else {
            return Fail(error: DirectoryError.pathDoesNotExists).eraseToAnyPublisher()
        }

        do {
            try fileManager.removeItem(atPath: directoryPath)
            print(
                "--- DELETED --- : ", directoryPath, "\n",
                "--- EXISTS --- :", fileManager.fileExists(atPath: directoryPath).description.uppercased()
            )

            return Just(true)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }

    func getUserPathURL(_ directory: DirectoryPath) -> URL? {
        // Get root user directory
        guard let libraryDirectory = fileManager.urls(for: .userDirectory, in: .localDomainMask).first else {
            return nil
        }

        let username = NSUserName()
        let derivedDataPath = libraryDirectory
            .appendingPathComponent("\(username)/\(directory.path)")

        print(
            "--- FILE --- : ", derivedDataPath.path(), "\n",
            "--- EXISTS --- :", fileManager.fileExists(atPath: derivedDataPath.path()).description.uppercased()
        )

        return derivedDataPath
    }
}

private extension DirectoryPath {
    var path: String {
        switch self {
        case .derivedData:
            return "Library/Developer/Xcode/DerivedData"

        case .test:
            return "Library/Developer/Xcode/Test"
        }
    }
}
