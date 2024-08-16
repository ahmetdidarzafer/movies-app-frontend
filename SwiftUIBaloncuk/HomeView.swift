//
//  HomeView.swift
    //  SwiftUIBaloncuk
//
//  Created by Ahmet Didar Zafer on 7.08.2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        TmdbView()
    }
}
#Preview {
    HomeView()
}
