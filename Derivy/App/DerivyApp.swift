//
//  DerivyApp.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
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