//
//  zoomiesApp.swift
//  zoomies
//
//  Created by Jakub Pietkiewicz on 09/10/2022.
//

// Import bibliotek SwiftUI i Firebase
import SwiftUI
import Firebase

// Definicja struct'a zoomiesApp jako głównej struktury aplikacji
@main
struct zoomiesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let persistenceController = PersistenceController.shared

    // Body aplikacji jest tworzone przez WindowGroup, w którym będzie wyświetlany ContentView
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate{
    var window: UIWindow?
    
    // Inicjalizacja storyboard'u z nazwą "Main"
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    
    // Funkcja wywoływana po zakończeniu inicjalizacji aplikacji
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Konfiguracja Firebase
        FirebaseApp.configure()
        
        // Inicjalizacja storyboard'u i ustawienie jego początkowego widoku
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateInitialViewController()
        self.window?.rootViewController = vc
        
        return true
    }
    
    // Funkcja resetująca aplikację
    func resetApp() {
        
        // Inicjalizacja storyboard'u i ustawienie jego początkowego widoku jako rootViewController okna
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window?.rootViewController = storyboard.instantiateInitialViewController()    }
}

// Klasa odpowiedzialna za delegowanie zdarzeń dotyczących okna aplikacji
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    // Funkcja wywoływana, gdy scena jest gotowa do użycia
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = UIHostingController(rootView: ContentView())
            self.window = window
            
            // Ustawienie okna jako główne i widoczne
            window.makeKeyAndVisible()
        }
    }
}



