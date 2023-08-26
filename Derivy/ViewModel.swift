//
//  ViewModel.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
//

import Combine
import Directory
import SwiftUI

final class ViewModel: ObservableObject {
    private let directory = Directory()

    @Published private(set) var deleteDerivedDataButtonTitle: String = .deleteDerivedData
    @Published private(set) var isDeriveDataDirectoryExist: Bool

    private let derivedDataDirectoryPath: DirectoryPath = .derivedData
    private var cancellables = Set<AnyCancellable>()

    init() {
        isDeriveDataDirectoryExist = directory.fileExists(at: derivedDataDirectoryPath)

        setupListener()
    }

    deinit {
        stopListeners()
    }

    func deleteDerivedData() {
        directory.deleteDirectory(at: derivedDataDirectoryPath)
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure = completion {
                    self.deleteDerivedDataButtonTitle = .derivedDataDoesNotExist
                    self.setDerivedDataButtonInitialTitle(after: 3)
                }
            } receiveValue: { [weak self] success in
                guard let self else {
                    return
                }

                self.deleteDerivedDataButtonTitle = .deleted
                self.setDerivedDataButtonInitialTitle(after: 3)
            }
            .store(in: &cancellables)
    }

    // MARK: - Private -

    private func setDerivedDataButtonInitialTitle(after seconds: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) { [weak self] in
            self?.deleteDerivedDataButtonTitle = .deleteDerivedData
        }
    }

    private func setupListener() {
        directory.startObserving(atPath: .xcode)
            .receive(on: RunLoop.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    debugPrint(error.localizedDescription)
                }
            } receiveValue: { [weak self] in
                self?.handleXcodeDirectoryUpdate()
            }
            .store(in: &cancellables)
    }

    private func stopListeners() {
        cancellables.forEach { $0.cancel() }
        directory.stopMonitoring()
    }

    private func handleXcodeDirectoryUpdate() {
        isDeriveDataDirectoryExist = directory.fileExists(at: derivedDataDirectoryPath)
    }
}

extension String {
    static let deleteDerivedData = "Delete Derived Data"
    static let deleted = "Derived Data has been deleted"
    static let derivedDataDoesNotExist = "Derived Data not found"
}
