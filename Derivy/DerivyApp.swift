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
        MenuBarExtra("Derivy", systemImage: "hammer.fill") {
            ContentView()

            Divider()
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
        }
    }
}
