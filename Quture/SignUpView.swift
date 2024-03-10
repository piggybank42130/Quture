//
//  SignUpView.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/8.
//

import SwiftUI

struct SignUpView: View {
    @Binding var isUserLoggedIn: Bool

    @State private var signUpUsername: String = ""
    @State private var signUpEmail: String = ""
    @State private var signUpPassword: String = ""

    var body: some View {
        VStack(spacing: 10) {
            Text("Sign Up")
                .font(.title)
            TextField("Username", text: $signUpUsername)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Email", text: $signUpEmail)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            SecureField("Password", text: $signUpPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Create Account") {
                // Perform sign-up action and set isUserLoggedIn to true upon success
                // For simplicity, we're just setting isUserLoggedIn to true here
                Task {
                    do {
                        let (newUserId) = try await ServerCommands().addUser(username: signUpUsername, email: signUpEmail, passwordHash: signUpPassword)

                        DispatchQueue.main.async {
                            LocalStorage().saveNumber(number: newUserId, to: "userId.txt")
                            
                            isUserLoggedIn = true
                        }
                    }
                    catch {
                        print(error) // Handle error
                        // Make sure to handle UI update on main thread if necessary
                    }
                }
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
