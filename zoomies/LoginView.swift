//
//  LoginView.swift
//  zoomies
//
//  Created by Jakub Pietkiewicz on 27/10/2022.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Firebase
// Ekran logowania
struct LoginView: View {
    @StateObject var loginModel: LoginViewModel = .init()
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 10.0) {
                Image("LoginScreenIcon")
                    .resizable()
                    .frame(width: 300, height: 300, alignment: .center)
                (Text("Zoomies")
                )
                .font(.title)
                .fontWeight(.semibold)
                .lineSpacing(10)
                HStack(spacing: 8){
                    // Przycisk logowania kontem Google
                    CustomButton(isGoogle: true)
                    .overlay {
                        if let clientID = FirebaseApp.app()?.options.clientID{
                            GoogleSignInButton{
                                GIDSignIn.sharedInstance.signIn(with: .init(clientID: clientID), presenting: UIApplication.shared.rootController()){user,error in
                                    if let error = error{
                                        print(error.localizedDescription)
                                        return
                                    }
                                    if let user{
                                        loginModel.logGoogleUser(user: user)
                                    }
                                }
                            }
                            .blendMode(.overlay)
                        }
                    }
                    .clipped()
                }
                .frame(maxWidth: .infinity)
            }.padding()

        }
        .alert(loginModel.errorMessage, isPresented: $loginModel.showError) {
        }
    }
    
    // Przycisk logowania kontem Google
    @ViewBuilder
    func CustomButton(isGoogle: Bool = false)->some View{
        HStack{
            Group{
                Image("google")
                    .resizable()
                    .renderingMode(.template)
            }
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .frame(height: 45)

            Text("Sign in with Google")
                .font(.callout)
                .lineLimit(1)
        }
        .foregroundColor(.white)
        .padding(.horizontal,15)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.
                      black)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
