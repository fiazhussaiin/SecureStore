


import SwiftUI

struct ContentView: View {
    @State private var isLocked: Bool = true
    @State private var isAuthenticated: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                // Buttons in a VStack with custom star shape
                VStack(spacing: 40) {
                    if isLocked && !isAuthenticated {
                        LockView(isLocked: $isLocked, isAuthenticated: $isAuthenticated)
                            
                    } else {
                        NavigationLink(destination: PasswordVaultView()) {
                            VStack {
                                StarShape()
                                    .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                                         startPoint: .topLeading,
                                                         endPoint: .bottomTrailing))
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Image(systemName: "key.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                            .opacity(0.4)  // Set icon opacity to 0.4
                                    )
                                Text("Passwords")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                        .onTapGesture {
                            if !isAuthenticated {
                                isLocked = true
                            }
                        }
                        
                        NavigationLink(destination: ImageVaultView()) {
                            VStack {
                                StarShape()
                                    .fill(LinearGradient(gradient: Gradient(colors: [.green, .blue]),
                                                         startPoint: .top,
                                                         endPoint: .bottomTrailing))
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Image(systemName: "lock.shield.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                            .opacity(0.4)  // Set icon opacity to 0.4
                                    )
                                Text("Images")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                        .onTapGesture {
                            if !isAuthenticated {
                                isLocked = true
                            }
                        }

                        // New Button for Auto-Generate Password
                        NavigationLink(destination: PasswordGeneratorView()) {
                            VStack {
                                StarShape()
                                    .fill(LinearGradient(gradient: Gradient(colors: [.red, .orange]),
                                                         startPoint: .top,
                                                         endPoint: .bottomTrailing))
                                    .frame(width: 90, height: 90)
                                    .overlay(
                                        Image(systemName: "gearshape.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                            .opacity(0.4)  // Set icon opacity to 0.4
                                    )
                                Text("Generate Password")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                }
                HStack {
                    Spacer()
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.red, .orange]),
                                             startPoint: .top,
                                             endPoint: .bottom))
                        .frame(width: 190, height: 80)
                        .offset(y: 40)
                    Spacer()
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                             startPoint: .leading,
                                             endPoint: .trailing))
                        .frame(width: 60, height: 160)
                        .offset(y: 50)
                    Spacer()
                }
                .padding(.bottom, 40)
            }
            .background(Color.white)  // Set background color
            .background(LinearGradient(gradient: Gradient(colors: [.green, .gray.opacity(0.8)]),
                                       startPoint: .top,
                                       endPoint: .bottom))  // Apply gradient background
            .ignoresSafeArea()
        }
    }
}
















import SwiftUI

struct StarShape: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let points = 8 // 8 corners
        let angle = (360.0 / Double(points)) * (Double.pi / 180.0)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        
        for i in 0..<points {
            let pointAngle = angle * Double(i)
            let point = CGPoint(
                x: center.x + radius * CGFloat(cos(pointAngle)),
                y: center.y + radius * CGFloat(sin(pointAngle))
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.closeSubpath()
        return path
    }
}

















import SwiftUI
import CryptoKit
import LocalAuthentication

struct LockView: View {
    @Binding var isLocked: Bool
    @Binding var isAuthenticated: Bool
    @State private var password: String = ""
    @State private var isPasswordSet: Bool = false
    @State private var isSettingPassword: Bool = false
    @State private var showForgotPasscodeAlert = false
    @State private var errorMessage: String? = nil
    
    // Retrieve the stored hashed password from UserDefaults
    private let storedPasswordKey = "storedPasswordHash"
    
    var body: some View {
        VStack {
            if isSettingPassword {
                Text("Set a New Password")
                    .font(.headline)
                    .padding()
                
                SecureField("New Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Save Password") {
                    if password.isEmpty {
                        errorMessage = "Password cannot be empty"
                    } else {
                        let hashedPassword = hashPassword(password)
                        UserDefaults.standard.set(hashedPassword, forKey: storedPasswordKey)
                        isPasswordSet = true
                        isSettingPassword = false
                        errorMessage = nil
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 20)
                
            } else if !isPasswordSet {
                Text("Set a Password")
                    .font(.headline)
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Save Password") {
                    if password.isEmpty {
                        errorMessage = "Password cannot be empty"
                    } else {
                        let hashedPassword = hashPassword(password)
                        UserDefaults.standard.set(hashedPassword, forKey: storedPasswordKey)
                        isPasswordSet = true
                        isLocked = false
                        errorMessage = nil
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 20)
                
            } else {
                Text("Enter Password")
                    .font(.headline)
                    .padding()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("Unlock") {
                    if password.isEmpty {
                        errorMessage = "Password cannot be empty"
                    } else if verifyPassword(password) {
                        isAuthenticated = true
                        isLocked = false
                        errorMessage = nil
                    } else {
                        errorMessage = "Incorrect password"
                    }
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding(.top, 20)
                
                Button("Forgot Passcode") {
                    showForgotPasscodeAlert = true
                }
                .padding()
                .foregroundColor(.blue)
                .alert(isPresented: $showForgotPasscodeAlert) {
                    Alert(
                        title: Text("Authenticate to Reset Passcode"),
                        message: Text("Use Face ID or Touch ID to authenticate and reset your passcode."),
                        primaryButton: .default(Text("Authenticate")) {
                            authenticateAndResetPassword()
                        },
                        secondaryButton: .cancel()
                    )
                }
            }
            
            if let message = errorMessage {
                Text(message)
                    .foregroundColor(.red)
                    .padding()
            }
        }
        .padding()
        .background(Color.white)  // Set background color
        .background(LinearGradient(gradient: Gradient(colors: [.yellow, .red]),
                                   startPoint: .top,
                                   endPoint: .bottom))  // Apply gradient background
        .ignoresSafeArea()
        .onAppear {
            // Check if password is already set
            if let _ = UserDefaults.standard.string(forKey: storedPasswordKey) {
                isPasswordSet = true
            } else {
                isSettingPassword = true
            }
        }
    }
    
    private func hashPassword(_ password: String) -> String {
        let passwordData = password.data(using: .utf8)!
        let hashed = SHA256.hash(data: passwordData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
    
    private func verifyPassword(_ inputPassword: String) -> Bool {
        let hashedPassword = hashPassword(inputPassword)
        return hashedPassword == UserDefaults.standard.string(forKey: storedPasswordKey)
    }
    
    private func authenticateAndResetPassword() {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Authenticate to reset your passcode"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Biometrics authenticated, allow password reset
                        UserDefaults.standard.set(nil, forKey: storedPasswordKey)
                        self.isSettingPassword = false
                        self.isPasswordSet = false
                        self.isLocked = false
                    } else {
                        // Authentication failed
                        self.errorMessage = "Authentication failed. Please try again."
                    }
                }
            }
        } else {
            // Biometrics not available
            self.errorMessage = "Biometric authentication is not available."
        }
    }
}
