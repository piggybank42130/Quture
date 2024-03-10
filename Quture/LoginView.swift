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
                Task {
                    do {
                        Task {
                            do {
                                let userId = try await ServerCommands().verifyUser(username: loginEmail, passwordHash: loginPassword)
                                DispatchQueue.main.async {
                                    LocalStorage().saveNumber(number: userId, to: "userId.txt")
                                    isUserLoggedIn = (userId != -1)
                                }
                            }
                            catch {
                                print(error)
                            }
                        }
                    }
                    catch {
                        print(error)
                    }
                }
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
    }



}


#Preview {
    ContentView()
}
