//
//  ContentView.swift
//  zoomies
//
//  Created by Jakub Pietkiewicz on 26/10/2022.
//
import Foundation
import SwiftUI
import HealthKit

// Główny widok aplikacji
struct ContentView: View {
    // Zmienne przechowujące główne dane potrzebne do poprawnego wyświetlenia
    @State var isReady = false
    @AppStorage("log_status") var logStatus: Bool = false
    @AppStorage("in_guild") var inGuild: Bool = false
    @AppStorage("guildCode") var guildCode: String = ""
    
    var body: some View {
        VStack {
            // Sprawdzenie czy użytkownik jest zalogowany
            if logStatus{
                VStack{
                    // Sprawdzenie czy użytkownik jest w gildii
                    if inGuild{
                        VStack{
                            // Sprawdzenie czy użytkownik zezwolił na dostęp do danych HealthKit
                            if isReady{
                                //Wyświetlenie strony domowej aplikacji
                                HomeView()
                            } else{
                                Text("Please authorize the application")
                            }
                        }.task {
                            // Sprawdzenie czy dane z HealthKit są dostępne i prośba o dostęp do nich
                            if !HKHealthStore.isHealthDataAvailable() {
                                return
                            }
                            guard await requestPermission() == true else {
                                return
                            }
                            isReady = true
                        }
                    }
                    else{
                        // Wyswietlenie ekranu tworzenia lub dołączania do gildii
                        JourneyStartView()
                    }
                }.task(){
                    // Wywołanie funkcji sprawdzajacej czy użytkownik należy do gildii
                    await checkGuild {
                        print("check after checkGuild: "+String(inGuild))
                    }
                        
                }
                
            }else{
                // Wyświetlenie widoku logowania
                LoginView()
            }
        }
    }
    
    
    // Wywołanie funkcji "checkGuild" z GCP
    func checkGuild(completion: @escaping () -> Void) async {
        do {
            let result = try await functions.httpsCallable("checkGuild").call()
            // Sprawdzenie czy response zawiera wymagane klucze
            if let data = result.data as? [String: Any],
                let response = data["hasGuild"] as? String,
                let code = data["code"] as? String
            {
                //Ustawienie globalnych zmiennych
                if response == "true" {
                    inGuild = true
                    guildCode = code
                } else {
                    inGuild = false
                }
            }
            //Wyświetlenie błędu jeśli wystąpił
        } catch let error {
            print(error)
        }
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
