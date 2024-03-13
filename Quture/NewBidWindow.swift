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

    @State private var bidAmount: String = ""
    
    @State private var sellerPrice: Double = 1000.00
    @State private var customerPrice: Double = -1.0
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
                    Text("\(sellerPrice, specifier: "%.2f")")
                        .bold()
                        .foregroundColor(isCustomerPriceActive ? .black : .white)
                    Text("Buy Now")
                        .foregroundColor(isCustomerPriceActive ? .black : .white)
                }
                .padding()
                .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50) // Explicit height set here
                .background(isCustomerPriceActive ? Color.gray.opacity(0.3) : Color.black)
                .cornerRadius(5)
                .onTapGesture {
                    self.isCustomerPriceActive = false
                }

                // "Highest Bet" box
                VStack {
                    Text("Make a Bid")
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
            if isCustomerPriceActive {
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
            .padding(.horizontal, 15)
        }
        .padding(.bottom, 20)
//        .frame(maxHeight: 300)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(radius: 10)
        .transition(.scale)
        .alert("Invalid Bid", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        .sheet(isPresented: $showTesterAlert) {
            // Now passing the missing 'price' argument
            CustomAlertView(isVisible: $showTesterAlert, sellerId: $sellerId, imageId: $imageId, price: $priceToShowInAlert, message: $message, phoneNumber: $phoneNumber)
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
    @Binding var sellerId: Int
    @Binding var imageId: Int
    @Binding var price: Double
    @Binding var message: String
    @Binding var phoneNumber: String
    @Environment(\.colorScheme) var colorScheme


    var body: some View {
        ZStack {
            // Setting the background color based on the color scheme
            colorScheme == .dark ? Color.black.edgesIgnoringSafeArea(.all) : Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                Text("Send a Purchase Offer")
                    .foregroundColor(Color.contrastColor(for: colorScheme)) // Ensure visibility against the white background
                    .font(.largeTitle) // Optionally adjust the font
                    .padding(12)
                Text("Price: $\(price, specifier: "%.2f")")
                    .foregroundColor(Color.contrastColor(for: colorScheme)) // Ensure visibility against the white background
                    .font(.headline) // Optionally adjust the font
                Text("Please enter your message to the seller:")
                    .foregroundColor(Color.contrastColor(for: colorScheme)) // Adjust as needed for visibility
                TextEditor(text: $message)
                    .frame(height: 120) // Adjust the height as needed, for example, three times a typical TextField height
                    .border(Color(UIColor.separator), width: 0.5) // Add a border similar to RoundedBorderTextFieldStyle
                    .padding(4) //
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Submit") {
                    if !message.isEmpty && !phoneNumber.isEmpty{
                        print("Message: \(message), Phone: \(phoneNumber)")
                        let message = "\(message)\n\nMy phone number is \(phoneNumber)"//Bid of $\(String(format: "%.2f", price)) placed with message: \(message) and contact: \(phoneNumber)"
                        Task{
                            do {
                                let newBidId = try await ServerCommands().addBid(sellerId: sellerId, buyerId: 1, imageId: imageId, messageText: message, isSellerResponse: false)
                            }
                            catch {
                                print(error)
                            }
                        }
                        isVisible = false
                    }
                }
            }
            .padding()
            .background(Color.sameColor(forScheme: colorScheme))
            .foregroundColor(Color.contrastColor(for: colorScheme))
            .cornerRadius(12)
            .shadow(radius: 8)
        }
    }
}
