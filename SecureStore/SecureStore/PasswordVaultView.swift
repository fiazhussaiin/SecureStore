
import SwiftUI

struct PasswordVaultView: View {
    @State private var passwords: [PasswordEntry] = []
    @State private var showAddPassword = false
    @State private var showAlert = false
    @State private var showDeleteAlert = false
    @State private var selectedPassword: PasswordEntry?
    @State private var toastMessage: String?
    
    var body: some View {
        NavigationView {
            VStack {
                if passwords.isEmpty {
                    Text("No passwords saved yet.")
                        .font(.title3)
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(passwords) { password in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text("Service: \(password.name)")
                                        .font(.headline)
                                    Text("Username: \(password.username)")
                                        .font(.subheadline)
                                    Text("Password: \(password.password)")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .contextMenu {
                                    Button(action: {
                                        UIPasteboard.general.string = password.password
                                        showToast(message: "Password Copied!")
                                    }) {
                                        Label("Copy", systemImage: "doc.on.doc")
                                    }
                                    
                                    Button(action: {
                                        sharePassword(password: password)
                                    }) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                    
                                    Button(action: {
                                        selectedPassword = password
                                        showDeleteAlert = true
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                }
            }
            .onAppear{
                loadPasswordsFromUserDefaults()
            }
            .navigationTitle("Secured Passwords")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        self.showAddPassword = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title)
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showAddPassword) {
                AddPasswordView(passwords: $passwords)
            }
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete Password"),
                    message: Text("Are you sure you want to delete this password?"),
                    primaryButton: .destructive(Text("Delete"), action: {
                        if let selectedPassword = selectedPassword {
                            if let index = passwords.firstIndex(where: { $0.id == selectedPassword.id }) {
                                passwords.remove(at: index)
                                savePasswordsToUserDefaults()
                            }
                        }
                    }),
                    secondaryButton: .cancel()
                )
            }
            .overlay(
                toastMessage.map {
                    Text($0)
                        .font(.body)
                        .padding()
                        .background(Color.black.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .transition(.slide)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation {
                                    toastMessage = nil
                                }
                            }
                        }
                }
                .padding(.bottom, 50), alignment: .bottom
            )
            .onAppear(perform: loadPasswordsFromUserDefaults)
        }
    }
    
    func showToast(message: String) {
        toastMessage = message
    }
    
    func sharePassword(password: PasswordEntry) {
        let shareText = "Service: \(password.name)\nUsername: \(password.username)\nPassword: \(password.password)"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    // Save passwords to UserDefaults
    func savePasswordsToUserDefaults() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(passwords)
            UserDefaults.standard.set(data, forKey: "savedPasswords")
        } catch {
            print("Failed to save passwords to UserDefaults: \(error)")
        }
    }
    
    // Load passwords from UserDefaults
    func loadPasswordsFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "savedPasswords") {
            do {
                let decoder = JSONDecoder()
                passwords = try decoder.decode([PasswordEntry].self, from: data)
            } catch {
                print("Failed to load passwords from UserDefaults: \(error)")
            }
        }
    }
}




import SwiftUI
import SwiftUI

struct AddPasswordView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var passwords: [PasswordEntry]
    @State private var name = ""
    @State private var username = ""
    @State private var password = ""
    @State private var category = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading) {
                    Text("Add New Password")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)

                    Text("Secure your credentials by adding a new password below.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 40)
                .padding(.horizontal, 24)

                // Form Fields
                VStack(spacing: 16) {
                    CustomTextField(iconName: "person.circle", placeholder: "Service Name", text: $name)
                    CustomTextField(iconName: "person.fill", placeholder: "Username", text: $username)
                    CustomSecureField(iconName: "lock.fill", placeholder: "Password", text: $password)
                    CustomTextField(iconName: "folder.fill", placeholder: "Category", text: $category)
                }
                .padding(.horizontal, 24)

                Spacer()

                // Save Button
                Button(action: addPassword) {
                    Text("Save Password")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(name.isEmpty || username.isEmpty || password.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                }
                .padding(.horizontal, 24)
                .disabled(name.isEmpty || username.isEmpty || password.isEmpty)
                .padding(.bottom, 40)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Message"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
            .navigationBarBackButtonHidden(true)
            .navigationBarItems(leading:
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.title)
                        .foregroundColor(.blue)
                }
            )
        }
    }

    func addPassword() {
        let newPassword = PasswordEntry(name: name, username: username, password: password, category: category, dateAdded: Date())
        passwords.append(newPassword)
        savePasswordsToUserDefaults(passwords: passwords)
        presentationMode.wrappedValue.dismiss()
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
}







struct CustomTextField: View {
    var iconName: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            TextField(placeholder, text: $text)
                .padding(.leading, 10)
                .padding(.vertical, 12)
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct CustomSecureField: View {
    var iconName: String
    var placeholder: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: iconName)
                .foregroundColor(.gray)
            SecureField(placeholder, text: $text)
                .padding(.leading, 10)
                .padding(.vertical, 12)
        }
        .padding(.horizontal)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    AddPasswordView(passwords: .constant([]))
}
