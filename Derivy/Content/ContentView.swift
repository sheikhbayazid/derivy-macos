//
//  ContentView.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

    var body: some View {
        errorMessage()
        deleteDerivedDataButton()
        quitButton()
    }

    @ViewBuilder
    private func errorMessage() -> some View {
        if let errorMessage = viewModel.errorMessage {
            Text(verbatim: errorMessage)
        }
    }

    @ViewBuilder
    private func deleteDerivedDataButton() -> some View {
        if viewModel.showIsDeletedDerivedData {
            Text(verbatim: Strings.Text.derivedDataHasBeenDeleted)
        } else if viewModel.isDeriveDataDirectoryExist {
            Button(
                Strings.Text.deleteDerivedData,
                action: viewModel.deleteDerivedData
            )
        } else {
            Text(verbatim: Strings.Text.derivedDataDoesNotExist)
        }
    }

    @ViewBuilder
    private func quitButton() -> some View {
        Divider()
        Button(Strings.Button.quit) {
            NSApplication.shared.terminate(nil)
        }
        .keyboardShortcut("q")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
