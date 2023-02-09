//
//  GuildView.swift
//  zoomies
//
//  Created by Jakub Pietkiewicz on 26/10/2022.
//

import SwiftUI

// Widok wewnątrz pierwszej zakładki ekranu głównego
struct GuildView: View {
    // Zmienna powiazana z modelem widoku
    @ObservedObject var data = GuildViewModel();
    
    var body: some View {
        VStack {
            // Wyświetlenie nazwy celu
            Text(data.goal.name)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            // Wygenerowanie i wwietlenie animowanej ikony z paskiem postępu do celu
            ProgressBarView(progress:CGFloat(data.goal.currentPoints)/CGFloat(data.goal.requiredPoints))
            // Wyświetlenie ilosci punktów
            Text(String(data.goal.currentPoints)+" / "+String(data.goal.requiredPoints))
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            // Wyświetlenie listy użytkownikow w gildii razem z ich punktami
            List(data.list) {Person in
                HStack {
                    AsyncImage(url: URL(string: Person.avatar)) { image in
                        image
                            .resizable()
                    } placeholder: {
                    }.clipShape(Circle())
                        .frame(width: 40, height: 40)
                        .aspectRatio(contentMode: .fill)
                    Text(Person.name)
                    Spacer()
                    Text(String(Person.points))
                }
            }
        }.task(){
            // Wywołanie funkcji zwracającej dane gildii (cel oraz użytkownicy) z GCP
            data.getData()
        }
    }
}

struct GuildView_Previews: PreviewProvider {
    static var previews: some View {
        GuildView()
    }
}
