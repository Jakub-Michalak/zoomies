//
//  SettingsView.swift
//  zoomies
//
//  Created by Jakub Pietkiewicz on 27/10/2022.
//

import SwiftUI
import Firebase
import GoogleSignIn

// Ekran ustawień
struct SettingsView: View {
    @AppStorage("log_status") var logStatus: Bool = false
    @State var isGuildAdmin: Bool = false
    @AppStorage("in_guild") var inGuild: Bool = false
    @AppStorage("guildCode") var guildCode: String = ""
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    // Widok
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("General")) {
                    Button("Logout") {
                        // Wylogowanie oraz reset aplikacji
                        try? Auth.auth().signOut()
                        GIDSignIn.sharedInstance.signOut()
                        withAnimation(.easeInOut) {
                            logStatus = false
                            if let delegate = appDelegate {
                                delegate.resetApp()
                            }
                        }
                    }
                    Button("Leave Guild") {
                        // Opuszczenie gildii oraz reset aplikacji
                        leaveGuild()
                        inGuild = false
                        if let delegate = appDelegate {
                            delegate.resetApp()
                        }
                    }
                }
                // Ładowanie tylko jeśli użytkownik jest administratorem
                if isGuildAdmin {
                    Section(header: Text("Guild Admin")) {
                        Button("DELETE GUILD") {
                            deleteGuild()
                            inGuild = false
                            if let delegate = appDelegate {
                                delegate.resetApp()
                            }
                        }
                        
                        NavigationLink("Kick user", destination: KickUserView())
                        NavigationLink("New goal", destination: NewGoalView())
                        
                    }
                }
                
            }
            .navigationBarTitle("Settings")
        }.onAppear{
            checkAdminPermissions()
        }
        
    }
    // Funkcja usuwające użytkownika z gildii przez funkcję GCP
    func leaveGuild(){
        functions.httpsCallable("leaveGuild").call(){ result, error in
            if let error = error as NSError? {
                print(error)
            }
            if let data = result?.data as? [String: Any], let response = data["status"] as? String {
                print(response)
                
                
            }
        }
    }
    // Funkcja sprawdzająca czy użytkownik jest administratorem gildii przez funkcję GCP
    func checkAdminPermissions(){
        functions.httpsCallable("checkAdminPermissions").call(){ result, error in
            if let error = error as NSError? {
                print(error)
            }
            if let data = result?.data as? [String: Any], let response = data["isAdmin"] as? String {
                if response == "true"{
                    isGuildAdmin = true
                }
                else{
                    isGuildAdmin = false
                }
            }
        }
    }
    // Funkcja usuwająca gildię przez funkcję GCP
    func deleteGuild(){
        functions.httpsCallable("deleteGuild").call(){ result, error in
            if let error = error as NSError? {
                print(error)
            }
            if let data = result?.data as? [String: Any], let response = data["status"] as? String {
                print(response)
                
                
            }
        }
    }
    
}
struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
