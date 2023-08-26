//
//  AuthorizationStatus+Extension.swift
//  Authentication
//
//  Created by Sheikh Bayazid on 2023-08-26.
//

import PermissionsKit

extension AuthorizationStatus {
    var status: AuthenticationStatus {
        switch self {
        case .notDetermined:
            return .notDetermined

        case .denied, .limited:
            return .denied

        case .authorized:
            return .authorized

        @unknown default:
            return .denied
        }
    }
}
