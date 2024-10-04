

import SwiftUI
import LocalAuthentication


@main
struct SecureStoreApp: App {
    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}

struct SplashScreen: View {
    @State private var isActive = true
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            if isActive {
                ContentView()
            } else {
                Image("logo")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .onAppear {
                        authenticateUser()
                    }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Authentication Failed"),
                  message: Text("Please try again."),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    private func authenticateUser() {
        let context = LAContext()
        var error: NSError?
        
//         Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to access the app"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Authentication successful, transition to ContentView
                        withAnimation {
                            isActive = true
                        }
                    } else {
                        // Authentication failed
                        showAlert = true
                    }
                }
            }
        } else {
            // Biometric authentication not available
            showAlert = true
        }
    }
}












import SwiftUI
import CryptoKit
import Combine

// MARK: - Password Model

struct PasswordEntry: Identifiable, Codable {
    var id = UUID()
    var name: String
    var username: String
    var password: String
    var category: String
    var dateAdded: Date
}


// MARK: - Image Model
import SwiftUI
import Foundation

struct ImageEntry: Identifiable, Codable {
    var id = UUID()
    var imageData: Data
    var category: String
    var dateAdded: Date
}


