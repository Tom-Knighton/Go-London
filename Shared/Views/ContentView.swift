//
//  ContentView.swift
//  Shared
//
//  Created by Tom Knighton on 01/10/2021.
//

import SwiftUI
import Introspect

struct ContentView: View {
    
    
    var body: some View {
        NavigationView {
            LinesOverviewView()
        }
        .navigationViewStyle(.stack)
    }
}
