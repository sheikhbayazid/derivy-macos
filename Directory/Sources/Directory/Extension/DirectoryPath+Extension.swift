//
//  DirectoryPath+Extension.swift
//  Directory
//
//  Created by Sheikh Bayazid on 2023-08-26.
//  Copyright © 2023 Sheikh Bayazid. All rights reserved.
//

import Foundation

extension DirectoryPath {
    /// Directory specific path.
    private var path: String {
        switch self {
        case .derivedData:
            return "Library/Developer/Xcode/DerivedData"

        case .xcode:
            return "Library/Developer/Xcode"

        case .test:
            return "Library/Developer/Xcode/Test"
        }
    }

    var directoryPath: String? {
        let fileManager = FileManager.default
        // Get root user directory
        guard let libraryDirectory = fileManager.urls(for: .userDirectory, in: .localDomainMask).first else {
            return nil
        }

        let username = NSUserName()
        let derivedDataPath = libraryDirectory
            .appendingPathComponent("\(username)/\(path)")

        print(
            "--- PATH --- : ", derivedDataPath.path(),
            "\n--- EXISTS --- :", fileManager.fileExists(atPath: derivedDataPath.path()).description.uppercased()
        )

        return derivedDataPath.path()
    }
}
