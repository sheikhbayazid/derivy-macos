//
//  ContentView.swift
//  Derivy
//
//  Created by Sheikh Bayazid on 26/8/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()

    var body: some View {
        if viewModel.isDeriveDataDirectoryExist {
            Button(
                viewModel.deleteDerivedDataButtonTitle,
                action: viewModel.deleteDerivedData
            )
        } else {
            Text(verbatim: .derivedDataDoesNotExist)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
