import SwiftUI

struct SignUpView: View {
    @Binding var isUserLoggedIn: Bool

    @State private var signUpUsername: String = ""
    @State private var signUpEmail: String = ""
    @State private var signUpPassword: String = ""
    @Environment(\.colorScheme) var colorScheme

    // States for image picker
    @State private var showImagePicker: Bool = false
    @State private var profileImage: UIImage? = nil

    var body: some View {
        ZStack {
            // Setting the background color based on the color scheme
            colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 10) {
                // Profile image picker circle
                Button(action: {
                    showImagePicker.toggle()
                }) {
                    if let profileImage = profileImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "camera")
                                    .foregroundColor(.white)
                            )
                    }
                }
                .padding(.bottom, 20)
                .sheet(isPresented: $showImagePicker) {
                    // Present the image picker
                    ImagePicker(image: $profileImage)
                }

                Text("Sign Up")
                    .font(.title)
                TextField("Username", text: $signUpUsername)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Email", text: $signUpEmail)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Password", text: $signUpPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Confirm Password", text: $signUpPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                Button("Create Account") {
                    // Perform sign-up action and set isUserLoggedIn to true upon success
                    Task {
                        do {
                            let newUserId = try await ServerCommands().addUser(username: signUpUsername, email: signUpEmail, passwordHash: signUpPassword)
                            DispatchQueue.main.async {
                                LocalStorage().saveUserId(number: newUserId)
                                isUserLoggedIn = true
                            }
                        }
                        catch {
                            print(error) // Handle error
                        }
                    }
                }
                .padding()
                .background(Color.sameColor(forScheme: colorScheme))
                .foregroundColor(.contrastColor(for: colorScheme))
                .cornerRadius(10)
                .font(.title)
                .frame(maxWidth: .infinity)
            }
            .padding()
        }
    }
}
