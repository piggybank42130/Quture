//
//  LoginView.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/8.
//

import SwiftUI

struct LoginView: View {
    @Binding var isUserLoggedIn: Bool
    @State private var showingSignUpView = false

    @State private var loginEmail: String = ""
    @State private var loginPassword: String = ""
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors
    @State private var showAlert = false
    @State private var alertMessage = ""

    let onLoginSuccess: () -> Void
    
    func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return predicate.evaluate(with: email)
    }

    func attemptLogin() {
        guard !loginEmail.isEmpty else {
            alertMessage = "Email cannot be empty."
            showAlert = true
            return
        }
        
        guard isValidEmail(loginEmail) else {
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return
        }
        
        guard !loginPassword.isEmpty else {
            alertMessage = "Password cannot be empty."
            showAlert = true
            return
        }

        loginUser()
    }

    func loginUser() {
        // Perform the login operation
        Task {
            do {
                let userId = try await ServerCommands().verifyUser(email: loginEmail, passwordHash: loginPassword)
                DispatchQueue.main.async {
                    LocalStorage().saveUserId(number: userId)
                    isUserLoggedIn = (userId != -1)
                    if isUserLoggedIn {
                        onLoginSuccess()
                    } else {
                        alertMessage = "Login failed. Please check your credentials."
                        showAlert = true
                    }
                }
            } catch {
                print(error)
                alertMessage = "An error occurred during login."
                showAlert = true
            }
        }
    }


    var body: some View {
        VStack(spacing: 20) {
            // Login Section
            VStack(spacing: 10) {
                Text("Login")
                    .font(.title)
                TextField("Email", text: $loginEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $loginPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()

            // Divider Line
            HStack {
                Spacer()
                VStack { Divider() }
                .frame(width: UIScreen.main.bounds.width * 0.4)
                Text("OR")
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                VStack { Divider() }
                .frame(width: UIScreen.main.bounds.width * 0.4)
                Spacer()
            }
            .padding(.vertical)

            // Sign Up Button
            Button("Create Account") {
                showingSignUpView = true
            }
            .padding()
            .background(Color.sameColor(forScheme: colorScheme))
            .foregroundColor(.contrastColor(for: colorScheme))
            .font(.headline)
            .cornerRadius(10)
            .frame(maxWidth: .infinity)
            .cornerRadius(0)


            // Confirm Button
            Button("Confirm") {
                attemptLogin()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.sameColor(forScheme: colorScheme))
            .foregroundColor(.contrastColor(for: colorScheme))
            .font(.headline)
            .cornerRadius(0)
            .padding(.horizontal)
        }
        .edgesIgnoringSafeArea(.bottom) // Allows the button to extend to the bottom edge
        .sheet(isPresented: $showingSignUpView) {
            SignUpView(isUserLoggedIn: $isUserLoggedIn)
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Login Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }



}


#Preview {
    ContentView()
}
