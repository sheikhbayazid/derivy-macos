//
//  DerivyApp.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
//  Copyright © 2023 Sheikh Bayazid. All rights reserved.
//

import SwiftUI

@main
struct DerivyApp: App {
    var body: some Scene {
        MenuBarExtra(
            Strings.Text.derivy,
            systemImage: Strings.SystemImage.hammer
        ) {
            ContentView()
        }
    }
}
