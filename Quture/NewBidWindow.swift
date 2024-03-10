import SwiftUI

struct NewBidWindow: View {
    @Binding var isVisible: Bool

    @State private var bidAmount: String = ""
    @State private var sellerPrice: Double = 1000.00
    @State private var customerPrice: Double = 950.00
    @State private var isCustomerPriceActive: Bool = false
    @State private var showTesterAlert: Bool = false
    @State private var message: String = ""
    @State private var phoneNumber: String = ""
    @FocusState private var isInputActive: Bool
    @State private var priceToShowInAlert: Double = 0.0 // Ensure this exists



    var body: some View {
        VStack(spacing: 15) {
            // Top bar with title and close button
            HStack {
                Spacer()
                Text("Please Make a Bid")
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
                        .foregroundColor(.white)
                    Text("Buy Now")
                        .foregroundColor(.white)
                }
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing], 10)
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .cornerRadius(5)
                .onTapGesture {
                    self.isCustomerPriceActive = false
                }

                // "Highest Bet" box
                VStack {
                    Text("\(customerPrice, specifier: "%.2f")")
                        .bold()
                        .foregroundColor(isCustomerPriceActive ? .white : .black)
                    Text("Highest Bet")
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
        .dismissKeyboardOnTap() // Apply the extension here
        .sheet(isPresented: $showTesterAlert) {
            // Now passing the missing 'price' argument
            CustomAlertView(isVisible: $showTesterAlert, price: $priceToShowInAlert, message: $message, phoneNumber: $phoneNumber)
        }

    }

    private func updatePrice() {
        if isCustomerPriceActive, let newPrice = Double(bidAmount), newPrice > 0 {
            customerPrice = newPrice
            priceToShowInAlert = newPrice
        } else {
            // If no new bid is entered, you might want to show the current highest bid/customer price
            priceToShowInAlert = customerPrice
        }
        bidAmount = "" // Clear input field after updating
        showTesterAlert = true // Prepare to show the alert
    }

}

struct CustomAlertView: View {
    @Binding var isVisible: Bool
    @Binding var price: Double
    @Binding var message: String
    @Binding var phoneNumber: String

    var body: some View {
        VStack {
            Text("Price: \(price, specifier: "%.2f")")
                .foregroundColor(.black) // Ensure visibility against the white background
                .font(.headline) // Optionally adjust the font
            Text("Please enter your contact information:")
                .foregroundColor(.black) // Adjust as needed for visibility
            TextField("Message to seller", text: $message)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Phone Number", text: $phoneNumber)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            Button("Submit") {
                print("Message: \(message), Phone: \(phoneNumber)")
                isVisible = false
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 8)
    }
}




struct NewBidWindow_Previews: PreviewProvider {
    static var previews: some View {
        // This wrapper view will simulate the external state that controls the visibility of NewBidWindow
        WrapperView()
    }

    struct WrapperView: View {
        @State private var isVisible = true // Initial state to show the NewBidWindow

        var body: some View {
            // Pass a binding to the isVisible state to NewBidWindow
            NewBidWindow(isVisible: $isVisible)
                .padding()
                .background(Color.gray.opacity(0.5)) // Optional: to help visualize the preview
        }
    }
}
