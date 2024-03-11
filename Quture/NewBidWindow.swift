import SwiftUI

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
                Text("Send a Purchase Request")
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
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing], 10)
                .frame(maxWidth: .infinity)
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
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing], 10)
                .frame(maxWidth: .infinity)
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

            Spacer()
        }
        .frame(width: 350, height: 300)
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
        let newPrice = Double(bidAmount) ?? -1
        customerPrice = isCustomerPriceActive ? newPrice : sellerPrice
        if (customerPrice > 0){
            priceToShowInAlert = customerPrice
            bidAmount = "" // Clear input field after updating
            showTesterAlert = true // Prepare to show the alert
            let notificationMessage = "New bid of $\(customerPrice) placed."
            print(notificationMessage)
        }
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
                Text("Price: \(price, specifier: "%.2f")")
                    .foregroundColor(Color.contrastColor(for: colorScheme)) // Ensure visibility against the white background
                    .font(.headline) // Optionally adjust the font
                Text("Please enter your contact information:")
                    .foregroundColor(.black) // Adjust as needed for visibility
                TextField("Message to seller", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField("Phone Number", text: $phoneNumber)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Submit") {
                    if !message.isEmpty && !phoneNumber.isEmpty{
                        print("Message: \(message), Phone: \(phoneNumber)")
                        let message = "Bid of $\(String(format: "%.2f", price)) placed with message: \(message) and contact: \(phoneNumber)"
                        Task{
                            do {
                                let newBidId = try await ServerCommands().addBid(sellerId: sellerId, buyerId: 1, imageId: imageId, messageText: message)
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
