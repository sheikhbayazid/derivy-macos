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
    public init() { }

    public func deleteDirectory(at directory: DirectoryPath) -> AnyPublisher<Bool, Error> {
        guard let directoryPath = getUserPathURL(directory)?.path(),
              FileManager.default.fileExists(atPath: directoryPath) else {
            return Fail(error: DirectoryError.pathDoesNotExists).eraseToAnyPublisher()
        }

        do {
            try FileManager.default.removeItem(atPath: directoryPath)
            print(
                "--- DELETED --- : ", directoryPath, "\n",
                "--- EXISTS --- :", FileManager.default.fileExists(atPath: directoryPath).description.uppercased()
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
        guard let libraryDirectory = FileManager.default.urls(for: .userDirectory, in: .localDomainMask).first else {
            return nil
        }

        let username = NSUserName()
        let derivedDataPath = libraryDirectory
            .appendingPathComponent("\(username)/\(directory.path)")

        print(
            "--- FILE --- : ", derivedDataPath.path(), "\n",
            "--- EXISTS --- :", FileManager.default.fileExists(atPath: derivedDataPath.path()).description.uppercased()
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
