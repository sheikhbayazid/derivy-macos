//
//  ContentViewModel.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
//  Copyright © 2023 Sheikh Bayazid. All rights reserved.
//

import Authentication
import Combine
import Directory
import SwiftUI

final class ContentViewModel: ObservableObject {
    private let authentication = Authentication()
    private let directory = Directory()

    @Published var observer: NSKeyValueObservation?
    @Published private(set) var errorMessage: String?

    @Published private(set) var shouldAskForPermission = false
    @Published private(set) var isDerivedDataDeletable: Bool
    @Published private(set) var showIsDeletedDerivedData: Bool = false

    private let derivedDataDirectoryPath: DirectoryPath = .test
    private var cancellables = Set<AnyCancellable>()

    init() {
        isDerivedDataDeletable = directory.isDeletableFile(at: derivedDataDirectoryPath)

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

                self.shouldAskForPermission = status != .authorized
                self.observedXcodeDirectory()
            })
            .store(in: &cancellables)
    }

    func deleteDerivedData() {
        directory.deleteDirectory(at: derivedDataDirectoryPath)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.setErrorMessage(Strings.Text.couldNotDeleteDerivedData)
                }
            } receiveValue: { [weak self] in
                self?.handleDeletedDerivedData()
            }
            .store(in: &cancellables)
    }

    // MARK: - Private -

    private func resetIsDeletedShowDerivedData(after seconds: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) { [weak self] in
            self?.showIsDeletedDerivedData = false
        }
    }

    private func setupListeners() {
        authentication.shouldAskForPermission
            .receive(on: RunLoop.main)
            .assign(to: &$shouldAskForPermission)

        observedXcodeDirectory()
    }

    private func observedXcodeDirectory() {
        directory.startObserving(atPath: .xcode)
            .receive(on: RunLoop.main)
            .sink { completion in
                if case let .failure(error) = completion {
                    debugPrint(error)
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

    private func handleDeletedDerivedData() {
        self.showIsDeletedDerivedData = true
        self.removeErrorMessage()
        self.resetIsDeletedShowDerivedData(after: 5)
    }

    private func handleXcodeDirectoryUpdate() {
        isDerivedDataDeletable = directory.isDeletableFile(at: derivedDataDirectoryPath)
    }

    private func setErrorMessage(_ message: String) {
        errorMessage = message
    }

    private func removeErrorMessage() {
        errorMessage = nil
    }
}
