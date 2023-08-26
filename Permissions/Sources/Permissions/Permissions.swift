import Combine
import Foundation
import PermissionsKit

public enum Status: String {
    case authorized
    case denied
    case notDetermined
}

public final class Permissions {
    public lazy var shouldAskForPermission = shouldAskForPermissionSubject.eraseToAnyPublisher()
    private var shouldAskForPermissionSubject = CurrentValueSubject<Bool, Never>(false)

    private let userDefault = UserDefaults.standard

    public init() { }

    public func requestFullDiskAccess() -> AnyPublisher<Status, Never> {
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
        guard let statusRawValue = userDefault.string(forKey: .fullDiskPermissionStatusKey),
              let status = Status(rawValue: statusRawValue) else {
            return .init(true)
        }

        return .init(status != .authorized)
    }

    private func saveStatus(_ status: Status) {
        userDefault.set(status.rawValue, forKey: .fullDiskPermissionStatusKey)
        shouldAskForPermissionSubject.send(status != .authorized)
    }
}

// MARK: - Extensions -

extension AuthorizationStatus {
    var status: Status {
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

private extension String {
    static let fullDiskPermissionStatusKey = "fullDiskPermissionStatus"
}
