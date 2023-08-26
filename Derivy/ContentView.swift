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
            Button("Grant Access") {
                viewModel.requestFullDiskPermission()
            }

            Button("Delete derived data") {
                // Grant access
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
