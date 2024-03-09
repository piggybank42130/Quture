//
//  LoginView.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/8.
//

import SwiftUI

struct LoginView: View {
    @Binding var isUserLoggedIn: Bool

    @State private var signUpEmail: String = ""
    @State private var signUpPassword: String = ""
    @State private var loginEmail: String = ""
    @State private var loginPassword: String = ""

    var body: some View {
        VStack(spacing: 20) {
            // Sign Up Section
            VStack(spacing: 10) {
                Text("Sign Up")
                    .font(.title)
                TextField("Email", text: $signUpEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $signUpPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .padding()

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

            // Confirm Button
            Button("Confirm") {
                // Perform login or sign up action and set isUserLoggedIn to true upon success
                // For simplicity, we're just setting isUserLoggedIn to true here
                isUserLoggedIn = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
    }
}



#Preview {
    ContentView()
}
