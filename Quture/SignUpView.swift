//
//  SignUpView.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/8.
//

import SwiftUI

struct SignUpView: View {
    @Binding var isUserLoggedIn: Bool

    @State private var signUpEmail: String = ""
    @State private var signUpPassword: String = ""

    var body: some View {
        VStack(spacing: 10) {
            Text("Sign Up")
                .font(.title)
            TextField("Email", text: $signUpEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $signUpPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Create Account") {
                // Perform sign-up action and set isUserLoggedIn to true upon success
                // For simplicity, we're just setting isUserLoggedIn to true here
                isUserLoggedIn = true
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
