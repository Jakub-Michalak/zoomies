import SwiftUI
import FirebaseFunctions

var functions = Functions.functions()
// Ekran wyboru tworzenia lub dołączania do gildii
struct JourneyStartView: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Join or create a guild")
                    .font(.title)
                HStack{
                    NavigationLink(destination: CreateGuildView()) {
                        Text("Create")
                    }.padding()
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(5)
                    NavigationLink(destination: JoinGuildView()) {
                        Text("Join")
                    }.padding()
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(5)
                }
                Spacer()
            }
        }
    }
}
// Ekran tworzenia gildii
struct CreateGuildView: View {
    @State private var guildName = ""
    @State private var code = ""
    @State var confirmed = false
    @State private var isLoading = false
    @AppStorage("in_guild") var inGuild: Bool = false
    // Widok
    var body: some View {
        ZStack{
            VStack(spacing: 20){
                TextField("Guild Name", text: $guildName)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                NavigationLink(destination: GuildInviteView(inviteCode: code), isActive: $confirmed, label: {
                    Button(action: {
                        createGuild()
                    }, label: {
                        Text("Confirm")
                        
                    }).padding()
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(5)
                })
                Spacer()
            }
            .navigationBarTitle("Create Guild")
            // Oznaczenie ładowania
            if isLoading{
                ProgressView()
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .scaleEffect(3)
            }
        }
    }
    // Funkcja dodająca użytkownika do gildii przez funkcję GCP
    func joinGuild(inviteCode: String){
        functions.httpsCallable("joinGuild").call(["inviteCode": inviteCode]){ result, error in
            if let error = error as NSError? {
                print(error)
            }
            if let data = result?.data as? [String: Any], let response = data["status"] as? String {
                print(response)
                
                confirmed = true
                
            }
        }
    }
    // Funkcja tworząca gildię przez funkcję GCP
    func createGuild(){
        isLoading = true
        functions.httpsCallable("createGuild").call(["name": guildName]){ result, error in
            if let error = error as NSError? {
                print(error)
            }
            if let data = result?.data as? [String: Any], let responseCode = data["code"] as? String {
                print(responseCode)
                code = responseCode
                joinGuild(inviteCode: responseCode)
                confirmed = true
            }
        }
    }
}

// Ekran wyświetlania kodu zaproszenia oraz przycisków do udostępniania
struct GuildInviteView: View {
    @AppStorage("in_guild") var inGuild: Bool = false
    let inviteCode: String
    
    var body: some View {
        VStack {
            Text("Your invite code")
                .font(.title)
            // Kod zaproszenia
            HStack {
                Text(String(inviteCode.prefix(1)))
                    .frame(width: 25, height: 50)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                Text(String(inviteCode[inviteCode.index(inviteCode.startIndex, offsetBy: 1)]))
                    .frame(width: 25, height: 50)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                Text(String(inviteCode[inviteCode.index(inviteCode.startIndex, offsetBy: 2)]))
                    .frame(width: 25, height: 50)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                Text(String(inviteCode[inviteCode.index(inviteCode.startIndex, offsetBy: 3)]))
                    .frame(width: 25, height: 50)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                Text(String(inviteCode[inviteCode.index(inviteCode.startIndex, offsetBy: 4)]))
                    .frame(width: 25, height: 50)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                Text(String(inviteCode[inviteCode.index(inviteCode.startIndex, offsetBy: 5)]))
                    .frame(width: 25, height: 50)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
            }
            // Przyciski
            HStack{
                Button(action: {
                    // Wywołanie systemowego okrna udostępniania
                    let message = "Join my guild on Zoomies using my invite code: \(self.inviteCode)"
                    let activityController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
                    if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                       let window = windowScene.windows.first,
                       let rootViewController = window.rootViewController {
                        rootViewController.present(activityController, animated: true, completion: nil)
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share")
                }.padding()
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(5)
                Button(action: {
                    // Skopiowanie kodu do schowka
                    UIPasteboard.general.string = self.inviteCode
                }) {
                    Image(systemName: "doc.on.doc")
                    Text("Copy")
                }.padding()
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(5)
                Button(action: {
                    inGuild = true
                }) {
                    Text("Done")
                }.padding()
                    .foregroundColor(.white)
                    .background(Color.accentColor)
                    .cornerRadius(5)
            }
            Spacer()
        }
        .navigationBarTitle("Invite Code")
    }
}

// Ekran dołącznia do gildii
struct JoinGuildView: View {
    @State private var inviteCode = ""
    @State var confirmed = false
    @State private var isLoading = false
    // Widok
    var body: some View {
        ZStack{
            VStack(spacing: 20){
                TextField("Guild Name", text: $inviteCode)
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(5)
                NavigationLink(destination: GuildInviteView(inviteCode: inviteCode), isActive: $confirmed, label: {
                    Button(action: {
                        joinGuild(inviteCode: inviteCode)
                    }, label: {
                        Text("Confirm")
                    }).padding()
                        .foregroundColor(.white)
                        .background(Color.accentColor)
                        .cornerRadius(5)
                })
                Spacer()
            }
            .navigationBarTitle("Join Guild")
            if isLoading{
                ProgressView()
                    .padding(10)
                    .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8))
                    .scaleEffect(3)
            }
        }
    }
    // Funkcja dodająca użytkownika do gildii przez GCP
    func joinGuild(inviteCode: String){
        functions.httpsCallable("joinGuild").call(["inviteCode": inviteCode]){ result, error in
            if let error = error as NSError? {
                print(error)
            }
            if let data = result?.data as? [String: Any], let response = data["status"] as? String {
                print(response)
                
                confirmed = true
                
            }
        }
    }
}


struct JourneyStartView_Previews: PreviewProvider {
    static var previews: some View {
        JourneyStartView()
    }
}
