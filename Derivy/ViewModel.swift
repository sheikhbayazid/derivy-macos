//
//  ViewModel.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
//

import Combine
import Directory
import Permissions
import SwiftUI

final class ViewModel: ObservableObject {
    private let directory = Directory()
    private let permissions = Permissions()

    @Published private(set) var shouldAskForPermission = false
    @Published private(set) var permissionStatus = Status.notDetermined

    @Published private(set) var deleteDerivedDataButtonTitle: String = .deleteDerivedData
    @Published private(set) var isDeriveDataDirectoryExists: Bool

    private let derivedDataDirectoryPath: DirectoryPath = .test
    private var cancellables = Set<AnyCancellable>()

    init() {
        isDeriveDataDirectoryExists = directory.fileExists(at: derivedDataDirectoryPath)

        setupListeners()
    }

    func requestFullDiskPermission() {
        permissions.requestFullDiskAccess()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                // Do Nothing for now.
            }, receiveValue: { [weak self] status in
                guard let self else {
                    return
                }

                self.permissionStatus = status
            })
            .store(in: &cancellables)
    }

    func deleteDerivedData() {
        directory.deleteDirectory(at: .test)
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
        permissions.shouldAskForPermission
            .receive(on: RunLoop.main)
            .assign(to: &$shouldAskForPermission)

        observedXcodePath()
    }

    private func observedXcodePath() {
        directory.startObserving(directory: .xcode) { [weak self] in
            DispatchQueue.main.async {
                self?.handleXcodeDirectoryUpdate()
            }
        }
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
