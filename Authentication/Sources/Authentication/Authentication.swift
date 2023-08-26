//
//  Authentication.swift
//  Authentication
//
//  Created by Sheikh Bayazid on 2023-08-26.
//

import Combine
import Foundation
import PermissionsKit

public class Authentication {
    public lazy var shouldAskForPermission = shouldAskForPermissionSubject.eraseToAnyPublisher()
    private var shouldAskForPermissionSubject = CurrentValueSubject<Bool, Never>(false)

    private let userDefault = UserDefaults.standard
    private let fullDiskPermissionStatusKey = "fullDiskPermissionStatus"

    public init() { }

    public func requestFullDiskAccess() -> AnyPublisher<AuthenticationStatus, Never> {
        Future { promise in
            PermissionsKit.requestAuthorization(for: .fullDiskAccess) { [weak self] authStatus in
                let status = authStatus.status

                self?.saveStatus(status)
                promise(.success(status))
            }
        }
        .eraseToAnyPublisher()
    }

    // MARK: - Private -

    private func createShouldAskForPermissionSubject() -> CurrentValueSubject<Bool, Never> {
        guard let statusRawValue = userDefault.string(forKey: fullDiskPermissionStatusKey),
              let status = AuthenticationStatus(rawValue: statusRawValue) else {
            return .init(true)
        }

        return .init(status != .authorized)
    }

    private func saveStatus(_ status: AuthenticationStatus) {
        userDefault.set(status.rawValue, forKey: fullDiskPermissionStatusKey)
        shouldAskForPermissionSubject.send(status != .authorized)
    }
}
