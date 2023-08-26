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

    private var cancellables = Set<AnyCancellable>()

    init() {
        listenToPublishers()
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
            .sink {
                print($0)
            } receiveValue: { success in
                // handle success
            }
            .store(in: &cancellables)
    }

    private func listenToPublishers() {
        permissions.shouldAskForPermission
            .receive(on: RunLoop.main)
            .assign(to: &$shouldAskForPermission)
    }
}
