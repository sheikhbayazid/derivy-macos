import Combine
import XCTest
@testable import Directory

final class DirectoryTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.forEach { $0.cancel() }
    }

    func testFileExists() {
        let sut = makeSUT()
        let testDirectory = DirectoryPath.test

        guard createDirectory(at: testDirectory) else {
            XCTFail("Fail to create test directory")
            return
        }

        let exists = sut.fileExists(at: testDirectory)
        XCTAssertTrue(exists, "Newly created test path should exist")
    }

    func testDerivedDataDelete() {
        let sut = makeSUT()
        let derivedDataDirectory = DirectoryPath.derivedData
        let expectation = expectation(description: "Delete derived data")

        XCTAssertTrue(sut.fileExists(at: .derivedData), "File should exist to perform deletion")

        sut.deleteDirectory(at: derivedDataDirectory)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: {
                expectation.fulfill()
            }
            .store(in: &cancellables)

        wait(for: [expectation])
        XCTAssertFalse(sut.fileExists(at: .derivedData))
    }

    func testObserveXcodeDirectory() {
        let sut = makeSUT()
        let xcodeDirectory = DirectoryPath.xcode

        sut.deleteDirectory(at: xcodeDirectory)
            .sink { completion in
                if case let .failure(error) = completion {
                    XCTFail(error.localizedDescription)
                }
            } receiveValue: {
                XCTAssertTrue(true)
            }
            .store(in: &cancellables)
    }

    private func createDirectory(at directory: DirectoryPath) -> Bool {
        let fileManager = FileManager.default

        guard let directoryPath = directory.directoryPath else {
            return false
        }

        do {
            try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
            return true
        } catch {
            return false
        }
    }

    private func makeSUT() -> Directory {
        let directory = Directory()
        return directory
    }
}
