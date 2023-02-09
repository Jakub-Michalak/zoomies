//
//  GuildViewModel.swift
//  zoomies
//
//  Created by Jakub Pietkiewicz on 28/10/2022.
//

import Foundation
import SwiftUI
import Firebase
import FirebaseFirestore

// Definicje klas
struct Person: Identifiable, Hashable {
    var id: String
    var name: String
    var points: Int
    var avatar: String
}
struct Goal{
    var name: String
    var currentPoints: Int
    var requiredPoints: Int
}

class GuildViewModel: ObservableObject {
    @Published var list = [Person]()
    @Published var goal = Goal(name: "Loading ...", currentPoints: 0, requiredPoints: 1)
    @AppStorage("guildCode") var guildCode: String = ""

    var GuildId = ""
    
    // Funkcja pobierajaca dane gildii z GCP
    func getData() {
        // Inicjalizacja firebase
        let db = Firestore.firestore()
        GuildId = guildCode
        // Pobranie danych o użytkownikach z firebase oraz dodanie Listenera zwracającego zmienione dane w czasie rzeczywistym
        db.collection("Guilds").document(GuildId).collection("Users").addSnapshotListener{snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    DispatchQueue.main.async {
                        // Zapisanie otrzymanych danych w tablicy obiektów klasy Person
                        self.list = snapshot.documents.map {doc in
                            return Person(id: doc.documentID,
                                          name: doc["Name"] as? String ?? "",
                                          points: doc["CurrentScore"] as? Int ?? 0,
                                          avatar: doc["AvatarURL"] as? String ?? "")
                            
                        }
                    }
                }
            }
            else{
            }
        }
        // Pobranie danych o celu z firebase oraz dodanie Listenera zwracającego zmienione dane w czasie rzeczywistym
        db.collection("Guilds").document(GuildId).collection("Goals").document("CurrentGoal")
            .addSnapshotListener { documentSnapshot, error in
                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }
                guard let data = document.data() else {
                    print("Document data was empty.")
                    return
                }
                print("Current data: \(data)")
                // Zapisanue danych do obiektu klasy Goal
                self.goal = Goal(name: document.data()!["Name"] as! String ,
                                 currentPoints: document.data()!["CurrentPoints"] as! Int ,
                                 requiredPoints: document.data()!["RequiredPoints"] as! Int)
                print("Goal: \(self.goal)")
            }
    }
}
