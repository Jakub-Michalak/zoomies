//
//  KickUserView.swift
//  zoomies
//
//  Created by Jakub Pietkiewicz on 04/02/2023.
//

import SwiftUI
// Ekran usuwania użytkownika z gildii
struct KickUserView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var data = GuildViewModel();
    // Widok
    var body: some View {
        NavigationView(){
            VStack {
                Text("Kick user:")
                // Wyświetlenie listy użytkowników (z przyciskiem do usunięcia)
                List(data.list) {Person in
                    HStack {
                        AsyncImage(url: URL(string: Person.avatar)) { image in
                            image
                                .resizable()      // Error here
                        } placeholder: {
                            //put your placeholder here
                        }.clipShape(Circle())
                            .frame(width: 40, height: 40)
                            .aspectRatio(contentMode: .fill)
                        
                        
                        Text(Person.name)
                        Spacer()
                        Button(action: {
                            kickFromGuild(UID: Person.id)
                            self.presentationMode.wrappedValue.dismiss()

                        }) {
                            Image(systemName: "trash")
                        }.padding()
                            .foregroundColor(.white)
                            .background(Color.accentColor)
                            .cornerRadius(5)
                    }
                }
                Spacer()
            }.task {
                // Załadownie danych z firebase przed wyświetleniem
                data.getData()
            }
        }
    }
    // Funkcja usuwająca użytkownika z gildii przez funkcję GCP
    func kickFromGuild(UID: String){
        functions.httpsCallable("kickFromGuild").call(["kickedUserUID": UID]){ result, error in
            if let error = error as NSError? {
                print(error)
            }
            if let data = result?.data as? [String: Any], let response = data["status"] as? String {
                print(response)
            }
        }
    }
    
}

struct KickUserView_Previews: PreviewProvider {
    static var previews: some View {
        KickUserView()
    }
}
