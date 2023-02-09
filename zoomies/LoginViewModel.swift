import SwiftUI
import Firebase
import CryptoKit
import AuthenticationServices
import GoogleSignIn

class LoginViewModel: ObservableObject {
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    // Stan aplikacji
    @AppStorage("log_status") var logStatus: Bool = false
    // Przechwytywanie błędów
    func handleError(error: Error)async{
        await MainActor.run(body: {
            errorMessage = error.localizedDescription
            showError.toggle()
        })
    }
    // Logowanie użytkownika
    func logGoogleUser(user: GIDGoogleUser){
        Task{
            do{
                guard let idToken = user.authentication.idToken else{return}
                let accesToken = user.authentication.accessToken
                let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accesToken)
                try await Auth.auth().signIn(with: credential)
                await MainActor.run(body: {
                    withAnimation(.easeInOut){logStatus = true}
                })
            }catch{
                await handleError(error: error)
            }
        }
    }
}
// Extensions
extension UIApplication{
    func closeKeyboard(){
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    func rootController()->UIViewController{
        guard let window = connectedScenes.first as? UIWindowScene else{return .init()}
        guard let viewcontroller = window.windows.last?.rootViewController else{return .init()}
        
        return viewcontroller
    }
}
