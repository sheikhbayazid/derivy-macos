//
//  Strings.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 2023-08-27.
//  Copyright © 2023 Sheikh Bayazid. All rights reserved.
//

import Foundation

enum Strings {
    enum Button {
        static let allowPermission = "Allow Permission"
        static let deleteDerivedData = "Delete Derived Data"
        static let quit = "Quit"
    }
    enum SystemImage {
        static let hammer = "hammer.fill"
    }
    enum Text {
        static let derivy = "Derivy"

        static let derivedDataHasBeenDeleted = "Derived Data has been deleted ☑️"
        static let derivedDataDoesNotExist = "No Derived Data found"
        static let couldNotDeleteDerivedData = "Could not delete Derived Data ⚠️"
        static let permissionMissing = "Permission missing ⚠️"
        static let allowPermissionDescription = "Please allow permission in-order to delete Derived Data!"
    }
}
