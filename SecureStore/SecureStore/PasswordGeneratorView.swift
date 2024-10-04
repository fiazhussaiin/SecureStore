

import SwiftUI

struct PasswordGeneratorView: View {
    @State private var password = ""
    @State private var length: Double = 12
    @State private var includeNumbers = true
    @State private var includeSymbols = true
    @State private var includeUppercase = true
    @State private var includeLowercase = true
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var passwords: [PasswordEntry] = []
    @State private var savedPasswords: [String] = []

    var body: some View {
        VStack {
            

            Text("Password Generator")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 70)

            // Generated Password
            Text(password.isEmpty ? "Generated Password" : password)
                .font(.title2)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(15)
                .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 20)

            Spacer()

            // Options for generating passwords
            Form {
                Section(header: Text("Password Options").bold()) {
                    VStack(alignment: .leading, spacing: 10) {
                        // Slider for password length
                        HStack {
                            Text("Length: \(Int(length))")
                                .fontWeight(.semibold)
                            Spacer()
                        }

                        Slider(value: $length, in: 6...20, step: 1)
                            .accentColor(.blue)
                        
                        // Toggle switches for options
                        Toggle("Include Numbers", isOn: $includeNumbers)
                        Toggle("Include Symbols", isOn: $includeSymbols)
                        Toggle("Include Uppercase Letters", isOn: $includeUppercase)
                        Toggle("Include Lowercase Letters", isOn: $includeLowercase)
                    }
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
            .padding(.horizontal, 20)

            // Generate Button
            Button(action: generatePassword) {
                Text("Generate")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)

            // Action Buttons: Save, Copy, Share
            HStack(spacing: 30) {
                ActionButton(image: "tray.and.arrow.down.fill", label: "Save", color: .green, action: addPassword)
                ActionButton(image: "doc.on.doc.fill", label: "Copy", color: .blue, action: copyPassword)
                ActionButton(image: "square.and.arrow.up.fill", label: "Share", color: .orange, action: sharePassword)
            }
            .padding(.bottom, 40)
        }
        .onAppear{
            passwords = loadPasswordsFromUserDefaults()
        }
        .padding()
        .background(LinearGradient(gradient: Gradient(colors: [.red, .purple.opacity(0.8)]),
                                   startPoint: .top,
                                   endPoint: .bottom))
        .ignoresSafeArea()
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Action"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }

    // Function to generate password
    func generatePassword() {
        let numbers = "0123456789"
        let symbols = "!@#$%^&*()_-+=<>?{}[]|"
        let uppercaseLetters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        let lowercaseLetters = "abcdefghijklmnopqrstuvwxyz"
        
        var characters = ""
        
        if includeNumbers { characters += numbers }
        if includeSymbols { characters += symbols }
        if includeUppercase { characters += uppercaseLetters }
        if includeLowercase { characters += lowercaseLetters }
        
        if characters.isEmpty {
            alertMessage = "Please select at least one option."
            showAlert = true
            return
        }
        
        password = String((0..<Int(length)).map { _ in characters.randomElement()! })
    }

    // Function to save password (simulate saving)
    func savePassword() {
        if password.isEmpty {
            alertMessage = "No password to save!"
        } else {
            var currentPasswords = UserDefaults.standard.stringArray(forKey: "savedPasswords") ?? []
            currentPasswords.append(password) // Add the new password to the array
            UserDefaults.standard.set(currentPasswords, forKey: "savedPasswords") // Save the updated array
            savedPasswords = currentPasswords // Update the local state
            alertMessage = "Password saved successfully!"
        }
        showAlert = true
    }
    
    
    
    
    func addPassword() {
        let newPassword = PasswordEntry(name: "Auto Generated", username: "yourpassword", password: password, category: "", dateAdded: Date())
        passwords.append(newPassword)
        savePasswordsToUserDefaults(passwords: passwords)
  
    }

    // Save the passwords array to UserDefaults
    func savePasswordsToUserDefaults(passwords: [PasswordEntry]) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(passwords)
            UserDefaults.standard.set(data, forKey: "savedPasswords")
            alertMessage = "Password saved successfully!"
        } catch {
            alertMessage = "Failed to save password!"
        }
        showAlert = true
    }

    // Load the passwords array from UserDefaults
    func loadPasswordsFromUserDefaults() -> [PasswordEntry] {
        if let data = UserDefaults.standard.data(forKey: "savedPasswords") {
            do {
                let decoder = JSONDecoder()
                let savedPasswords = try decoder.decode([PasswordEntry].self, from: data)
                return savedPasswords
            } catch {
                alertMessage = "Failed to load passwords!"
                showAlert = true
            }
        }
        return []
    }
    
    
    
    
    
    
    
    
    
    
    

    // Load the passwords from UserDefaults


    // Function to copy password to clipboard
    func copyPassword() {
        if password.isEmpty {
            alertMessage = "No password to copy!"
        } else {
            UIPasteboard.general.string = password
            alertMessage = "Password copied to clipboard!"
        }
        showAlert = true
    }

    // Function to share password
    func sharePassword() {
        if password.isEmpty {
            alertMessage = "No password to share!"
        } else {
            let activityController = UIActivityViewController(activityItems: [password], applicationActivities: nil)
            if let topController = UIApplication.shared.windows.first?.rootViewController {
                topController.present(activityController, animated: true, completion: nil)
            }
        }
    }
}

// Action Button View for Save, Copy, Share buttons
struct ActionButton: View {
    var image: String
    var label: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Image(systemName: image)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.black)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .shadow(color: .gray.opacity(0.5), radius: 10, x: 0, y: 5)
        }
    }
}

#Preview {
    PasswordGeneratorView()
}
