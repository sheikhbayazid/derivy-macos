//
//  ViewModel.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
//

import Combine
import Permissions
import SwiftUI

final class ViewModel: ObservableObject {
    private let permissions = Permissions()

    @Published private(set) var shouldAskForPermission = false
    @Published private(set) var permissionStatus = Status.notDetermined

    private var cancellable: AnyCancellable?

    init() {
        listenToPublishers()
    }

    func requestFullDiskPermission() {
        cancellable = permissions.requestFullDiskAccess()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in
                // Do Nothing for now.
            }, receiveValue: { status in
                // do something with status
            })
    }

    private func listenToPublishers() {
        permissions.shouldAskForPermission
            .receive(on: RunLoop.main)
            .assign(to: &$shouldAskForPermission)
    }
}
