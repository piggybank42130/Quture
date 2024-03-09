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
            .background(Color.black)
            .foregroundColor(.white)
            .font(.headline)
            .cornerRadius(10)


            // Confirm Button
            Button("Confirm") {
                // Perform login action and set isUserLoggedIn to true upon success
                isUserLoggedIn = true
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.black)
            .foregroundColor(.white)
            .font(.headline)
            .cornerRadius(0)
            .padding(.horizontal)
        }
        .edgesIgnoringSafeArea(.bottom) // Allows the button to extend to the bottom edge
        .sheet(isPresented: $showingSignUpView) {
            SignUpView(isUserLoggedIn: $isUserLoggedIn)
        }
    }



}


#Preview {
    ContentView()
}
