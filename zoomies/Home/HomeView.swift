//
//  HomeView.swift
//  zoomies
//
//  Created by Jakub Pietkiewicz on 27/10/2022.
//

import SwiftUI

// Strona główna aplikacji
struct HomeView: View {
    var body: some View {
        // Wyświetlanie ekranow w zakładkach
        TabView(selection: /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Selection@*/.constant(1)/*@END_MENU_TOKEN@*/) {
            GuildView().tabItem() {
                Image(systemName: "person.3.fill");
                Text("Guild")
            }.tag(1)
            
            WorkoutsView().tabItem() {
                Image(systemName: "figure.run");
                Text("Workouts")
            }.tag(2)
            
            SettingsView().tabItem() {
                Image(systemName: "gear");
                Text("Settings")
            }.tag(3)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
