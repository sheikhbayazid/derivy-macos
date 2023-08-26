//
//  ContentViewModel.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
//  Copyright © 2023 Sheikh Bayazid. All rights reserved.
//

import Combine
import Directory
import SwiftUI

final class ContentViewModel: ObservableObject {
    private let directory = Directory()

    @Published private(set) var errorMessage: String?

    @Published private(set) var isDeriveDataDirectoryExist: Bool
    @Published private(set) var showIsDeletedDerivedData: Bool = false

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
            .sink { [weak self] completion in
                if case .failure = completion {
                    self?.setErrorMessage(Strings.Text.couldNotDeleteDerivedData)
                }
            } receiveValue: { [weak self] success in
                guard let self else {
                    return
                }

                self.showIsDeletedDerivedData = true
                self.removeErrorMessage()
                self.resetIsDeletedShowDerivedData(after: 5)
            }
            .store(in: &cancellables)
    }

    // MARK: - Private -

    private func resetIsDeletedShowDerivedData(after seconds: Int) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(seconds)) { [weak self] in
            self?.showIsDeletedDerivedData = false
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

    private func setErrorMessage(_ message: String) {
        errorMessage = message
    }

    private func removeErrorMessage() {
        errorMessage = nil
    }
}
