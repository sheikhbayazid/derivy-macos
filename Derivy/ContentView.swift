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
        VStack {
            if viewModel.shouldAskForPermission {
                Text("Please grant full disk permission in-order to access files.")

                Divider()
                Button("Grant Access", action: viewModel.requestFullDiskPermission)
            }

            Button("Delete derived data", action: viewModel.deleteDerivedData)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
