//
//  ContentView.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
//  Copyright © 2023 Sheikh Bayazid. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()
    
    var body: some View {
        errorMessage()
        
        if viewModel.shouldAskForPermission {
            allowPermissionDescriptionText()
            allowPermissionButton()
        } else {
            deleteDerivedDataContainer()
        }
        
        quitButton()
    }
    
    @ViewBuilder
    private func errorMessage() -> some View {
        if let errorMessage = viewModel.errorMessage {
            Text(verbatim: errorMessage)
        }
    }
    
    @ViewBuilder
    private func deleteDerivedDataContainer() -> some View {
        if viewModel.showIsDeletedDerivedData {
            derivedDataHasBeenDeletedText()
        } else if viewModel.isDerivedDataDeletable {
            deleteDerivedDataButton()
        } else {
            derivedDataDoesNotExistText()
        }
    }
    
    @ViewBuilder
    private func deleteDerivedDataButton() -> some View {
        Button(
            Strings.Button.deleteDerivedData,
            action: viewModel.deleteDerivedData
        )
    }
    
    @ViewBuilder
    private func allowPermissionButton() -> some View {
        Button(
            Strings.Button.allowPermission,
            action: viewModel.requestFullDiskPermission
        )
    }
    
    @ViewBuilder
    private func allowPermissionDescriptionText() -> some View {
        Text(verbatim: Strings.Text.permissionMissing)
        Text(verbatim: Strings.Text.allowPermissionDescription)
    }
    
    @ViewBuilder
    private func derivedDataHasBeenDeletedText() -> some View {
        Text(verbatim: Strings.Text.derivedDataHasBeenDeleted)
    }
    
    @ViewBuilder
    private func derivedDataDoesNotExistText() -> some View {
        Text(verbatim: Strings.Text.derivedDataDoesNotExist)
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
