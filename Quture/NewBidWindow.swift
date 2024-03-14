import SwiftUI
extension String {
    func DecimalPoint() -> Bool {
        let components = self.components(separatedBy: ".")
        return components.count <= 2
    }
}
struct NewBidWindow: View {
    @Binding var isVisible: Bool
    @State var sellerId: Int
    @State var imageId: Int
    var onBidPlaced: (() -> Void)?


    @State private var bidAmount: String = ""
    
    @State private var sellerPrice: Double = -2.0
    @State private var customerPrice: Double = -2.0
    @State private var isCustomerPriceActive: Bool = false
    @State private var showTesterAlert: Bool = false
    @State private var message: String = ""
    @State private var phoneNumber: String = ""
    @FocusState private var isInputActive: Bool
    @State private var priceToShowInAlert: Double = 0.0 // Ensure this exists
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Environment(\.colorScheme) var colorScheme
    //Vars to handle shared notifications model

    var body: some View {
        VStack(spacing: 15) {
            // Top bar with title and close button
            HStack {
                Spacer()
                Text("  Send a Purchase Offer")
                    .font(.headline)
                    .bold()
                    .foregroundColor(.black)
                Spacer()
                Button(action: {
                    self.isVisible = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                        .imageScale(.large)
                }
            }
            .padding()
            .background(.white)

            // Buy Now and Highest Bet boxes
            HStack {
                // "Buy Now" box
                VStack {
                    Text(sellerPrice == -1 ? "Not for sale" : "\(sellerPrice, specifier: "%.2f")")
                        .bold()
                        .foregroundColor(isCustomerPriceActive ? .black : .white)
                    if sellerPrice != -1 {
                        Text("Buy Now")
                            .foregroundColor(isCustomerPriceActive ? .black : .white)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50) // Explicit height set here
                .background(isCustomerPriceActive ? Color.gray.opacity(0.3) : Color.black)
                .cornerRadius(5)
                .onTapGesture {
                    self.isCustomerPriceActive = false
                }
                .onAppear{
                    Task{
                        do{
                            let (_, _, imagePrice, _) = try await ServerCommands().retrieveImage(imageId: imageId)
                            sellerPrice = imagePrice
                        } catch {
                            print(error)
                        }
                    }
                }

                // "Highest Bet" box
                VStack {
                    Text(sellerPrice == -1 ? "Not for sale" : "Make a Bid")
                        .foregroundColor(isCustomerPriceActive ? .white : .black)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50) // Same explicit height set here
                .background(isCustomerPriceActive ? Color.black : Color.gray.opacity(0.3))
                .cornerRadius(5)
                .onTapGesture {
                    self.isCustomerPriceActive = true
                }
            }
            .padding(.horizontal, 15)

            // Interactive text box for entering a price (only shown for Highest Bet)
            if isCustomerPriceActive && sellerPrice != -1  {
                ZStack(alignment: .leading) {
                    TextField("Enter your bid here", text: $bidAmount)
                        .padding(.leading, 20)
                        .foregroundColor(.black)
                        .keyboardType(.decimalPad)
                        .focused($isInputActive)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 1)
                        )
                    
                    Text("$")
                        .foregroundColor(.black)
                        .padding(.leading, 15)
                }
                .padding(.horizontal, 15)
            }

            if sellerPrice > -0.9 || sellerPrice < -2.1 {
                // Confirmation button
                Button(action: {
                    print("pushed")
                    updatePrice()
                }) {
                    Text("Confirm")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(10)
                }
                .disabled(sellerPrice == -2.0)
                .padding(.horizontal, 15)
            }
        }
        .padding(.bottom, 20)
//        .frame(maxHeight: 300)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
                        Group {
                            if sellerPrice == -2.0 {
                                ZStack {
                                    // Semi-transparent layer
                                    (colorScheme == .dark ? Color.black : Color.white)
                                        .opacity(0.5)
                                        .edgesIgnoringSafeArea(.all)
                                    
                                    // Loading indicator
                                    ProgressView("")
                                        .scaleEffect(1.5, anchor: .center)
                                        .progressViewStyle(CircularProgressViewStyle(tint: colorScheme == .dark ? .white : .black))
                                }
                            }
                        }
                    )
        .transition(.scale)
        .alert("Invalid Bid", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .sheet(isPresented: $showTesterAlert) {
                CustomAlertView(
                    isVisible: $showTesterAlert,
                    newBidWindowVisible: $isVisible, // Pass the isVisible binding of NewBidWindow
                    sellerId: $sellerId,
                    imageId: $imageId,
                    price: $priceToShowInAlert,
                    message: $message,
                    phoneNumber: $phoneNumber,
                    onBidPlaced: onBidPlaced // Pass the closure to CustomAlertView
                )
            }


    }

    private func updatePrice() {
        // Check if bidding is active and perform validations
        if isCustomerPriceActive {
            guard !bidAmount.isEmpty else {
                alertMessage = "Bid amount cannot be empty."
                showAlert = true
                return
            }
            
            guard bidAmount.DecimalPoint() else {
                alertMessage = "Bid amount cannot contain multiple decimal points."
                showAlert = true
                return
            }
            
            guard let newPrice = Double(bidAmount) else {
                alertMessage = "Invalid bid amount entered."
                showAlert = true
                return
            }

            guard newPrice <= 10_000 else {
                alertMessage = "Bid amount cannot exceed 10,000."
                showAlert = true
                return
            }
            
            customerPrice = newPrice
        } else {
            customerPrice = sellerPrice
        }
        
        // Proceed with showing the alert for a successful bid
        priceToShowInAlert = customerPrice
        bidAmount = "" // Clear input field after updating
        showTesterAlert = true // Indicate successful bid preparation
        let notificationMessage = "New bid of $\(customerPrice) placed."
        print(notificationMessage)
    }
}

struct CustomAlertView: View {
    @Binding var isVisible: Bool
    @Binding var newBidWindowVisible: Bool
    @Binding var sellerId: Int
    @Binding var imageId: Int
    @Binding var price: Double
    @Binding var message: String
    @Binding var phoneNumber: String
    var onBidPlaced: (() -> Void)?
    @State private var showSuccessAlert = false
    @State private var showAlert = false
    @State private var alertMessage = ""

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        ZStack {
            colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Send a Purchase Offer")
                    .foregroundColor(Color.contrastColor(for: colorScheme))
                    .font(.largeTitle)
                    .padding(12)
                Text("Price: $\(price, specifier: "%.2f")")
                    .foregroundColor(Color.contrastColor(for: colorScheme))
                    .font(.headline)
                Text("Please enter your message to the seller:")
                    .foregroundColor(Color.contrastColor(for: colorScheme))
                TextEditor(text: $message)
                    .frame(height: 120)
                    .border(Color(UIColor.separator), width: 0.5)
                    .padding(4)
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
                Button("Submit") {
                    if message.isEmpty || phoneNumber.isEmpty {
                        alertMessage = "Message and phone number cannot be empty."
                        showAlert = true
                    } else if !isValidPhoneNumber(phoneNumber) {
                        alertMessage = "Please enter a valid phone number."
                        showAlert = true
                    } else {
                        placeBid()
                    }
                    if !message.isEmpty && !phoneNumber.isEmpty {
                        print("Message: \(message), Phone: \(phoneNumber)")
                        let completeMessage = "\(message)\n\nMy phone number is \(phoneNumber)"
                        Task {
                            do {
                                let newBidId = try await ServerCommands().addBid(sellerId: sellerId, buyerId: LocalStorage().getUserId(), imageId: imageId, messageText: completeMessage, successful: false, isSellerResponse: false)
                                print("Bid placed successfully with ID: \(newBidId)")
                                showSuccessAlert = true // Show the success alert after placing the bid
                            } catch {
                                print("Error placing bid: \(error)")
                            }
                        }
                    }

                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                .alert("Success", isPresented: $showSuccessAlert) {
                    Button("Exit", role: .cancel) {
                        isVisible = false
                        newBidWindowVisible = false
                        onBidPlaced?()
                    }
                } message: {
                    Text("You have made a successful bid.")
                }
            }
            .padding()
            .background(Color.sameColor(forScheme: colorScheme))
            .foregroundColor(Color.contrastColor(for: colorScheme))
            .cornerRadius(12)
            .shadow(radius: 8)
        }
    }

    func isValidPhoneNumber(_ phoneNumber: String) -> Bool {
        let phoneNumberRegex = "^[+]?[0-9]{1,3}[-\\s]?\\(?[0-9]{1,4}\\)?[-\\s]?[0-9]{1,4}[-\\s]?[0-9]{1,4}([-\\s]?[0-9]{1,4})?$"
        let regexPredicate = NSPredicate(format:"SELF MATCHES %@", phoneNumberRegex)
        let isValidStructure = regexPredicate.evaluate(with: phoneNumber)
        let isValidLength = phoneNumber.count <= 15 // Enforce maximum length
        
        return isValidStructure && isValidLength
    }


    func placeBid() {
        
        guard isValidPhoneNumber(phoneNumber) else {
                alertMessage = "Please enter a valid phone number."
                showAlert = true
                return // Exit the function early if validation fails
            }
        
        let completeMessage = "\(message)\n\nMy phone number is \(phoneNumber)"
        Task {
            do {
                let newBidId = try await ServerCommands().addBid(sellerId: sellerId, buyerId: LocalStorage().getUserId(), imageId: imageId, messageText: completeMessage, successful: false, isSellerResponse: false)
                print("Bid placed successfully with ID: \(newBidId)")
                showSuccessAlert = true
            } catch {
                print("Error placing bid: \(error)")
            }
        }
    }
}



