import SwiftUI

struct SignUpView: View {
    @Binding var isUserLoggedIn: Bool

    @State private var signUpUsername: String = ""
    @State private var signUpEmail: String = ""
    @State private var signUpPassword: String = ""
    @Environment(\.colorScheme) var colorScheme
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var confirmPassword: String = ""



    // States for image picker
    @State private var showImagePicker: Bool = false
    @State private var profileImage: UIImage? = nil
    
    func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let predicate = NSPredicate(format:"SELF MATCHES %@", emailPattern)
        return predicate.evaluate(with: email)
    }

    func isValidPassword(_ password: String) -> Bool {
        // Modified to remove the number requirement
        let passwordPattern = "(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[a-z]).{8,}"
        let predicate = NSPredicate(format: "SELF MATCHES %@", passwordPattern)
        return predicate.evaluate(with: password)
    }

    
    func validateFormData() {
        if signUpUsername.isEmpty || signUpEmail.isEmpty || signUpPassword.isEmpty || confirmPassword.isEmpty {
            alertMessage = "Please fill in all fields."
            showAlert = true
            return
        }
        
        if !isValidEmail(signUpEmail) {
            alertMessage = "Please enter a valid email address."
            showAlert = true
            return
        }
        
        if signUpPassword != confirmPassword {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        
        if !isValidPassword(signUpPassword) {
                    alertMessage = "Password must be at least 8 characters, include a special character, and an uppercase letter."
                    showAlert = true
                    return
                }

        // If all validations pass
        createAccount()
    }
    
    func createAccount() {
        // Perform sign-up action and set isUserLoggedIn to true upon success
        Task {
            do {
                let newUserId = try await ServerCommands().addUser(username: signUpUsername, email: signUpEmail, passwordHash: signUpPassword)
                if let profileImage = profileImage{
                    try await ServerCommands().uploadProfilePicture(userId: newUserId, image: profileImage)
                }else{
                }
                DispatchQueue.main.async {
                    LocalStorage().saveUserId(number: newUserId)
                    isUserLoggedIn = true
                }
            }
            catch {
            }
        }
    }

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
                            .frame(width: 150, height: 150)
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
                SecureField("Password (8+ chars, 1 special, 1 uppercase)", text: $signUpPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Create Account") {
                    validateFormData()

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
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Validation Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }

    }
}
