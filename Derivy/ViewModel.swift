//
//  ViewModel.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
//

import Authentication
import Combine
import Directory
import SwiftUI

final class ViewModel: ObservableObject {
    private let authentication = Authentication()
    private let directory = Directory()

    @Published private(set) var shouldAskForPermission = false
    @Published private(set) var permissionStatus = AuthenticationStatus.notDetermined

    @Published private(set) var deleteDerivedDataButtonTitle: String = .deleteDerivedData
    @Published private(set) var isDeriveDataDirectoryExists: Bool

    private let derivedDataDirectoryPath: DirectoryPath = .test
    private var cancellables = Set<AnyCancellable>()

    init() {
        isDeriveDataDirectoryExists = directory.fileExists(at: derivedDataDirectoryPath)

        setupListeners()
    }

    deinit {
        stopListeners()
    }

    func requestFullDiskPermission() {
        authentication.requestFullDiskAccess()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] status in
                guard let self else {
                    return
                }

                self.permissionStatus = status
            })
            .store(in: &cancellables)
    }

    func deleteDerivedData() {
        directory.deleteDirectory(at: derivedDataDirectoryPath)
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure = completion {
                    self.deleteDerivedDataButtonTitle = .fileDoesNotExists
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

    private func setupListeners() {
        authentication.shouldAskForPermission
            .receive(on: RunLoop.main)
            .assign(to: &$shouldAskForPermission)

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
        isDeriveDataDirectoryExists = directory.fileExists(at: derivedDataDirectoryPath)
    }
}

extension String {
    static let deleteDerivedData = "Delete derived data"
    static let deleted = "Deleted"
    static let fileDoesNotExists = "File does not exists"
}
