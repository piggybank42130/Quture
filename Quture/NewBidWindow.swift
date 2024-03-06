//
//  NewBidWindow.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/5.
//


import SwiftUI

struct NewBidWindow: View {
    @Binding var isVisible: Bool

    @State private var bidAmount: String = ""
    @State private var sellerPrice: Double = 1000.00 // Initialize with default values or use passed-in values
    @State private var customerPrice: Double = 950.00
    @State private var isSellerPriceActive: Bool = true // To track which price is currently being updated

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
                // "Buy Now" box with adjusted padding to make it flatter and pushed to the edge
                VStack {
                    Text("\(sellerPrice, specifier: "%.2f")")
                        .bold()
                        .foregroundColor(isSellerPriceActive ? .white : .black)
                    Text("Buy Now")
                        .foregroundColor(isSellerPriceActive ? .white : .black)
                }
                .padding([.top, .bottom], 8) // Reduced vertical padding to make it flatter
                .padding([.leading, .trailing], 10) // Horizontal padding for internal spacing
                .frame(maxWidth: .infinity) // Ensures the box stretches to fill the available space
                .background(isSellerPriceActive ? Color.black : Color.gray)
                .cornerRadius(5)
                .onTapGesture {
                    self.isSellerPriceActive = true
                }

                // "Highest Bet" box with adjusted padding to make it flatter and pushed to the edge
                VStack {
                    Text("\(customerPrice, specifier: "%.2f")")
                        .bold()
                        .foregroundColor(isSellerPriceActive ? .black : .white)
                    Text("Highest Bet")
                        .foregroundColor(isSellerPriceActive ? .black : .white)
                }
                .padding([.top, .bottom], 8) // Reduced vertical padding to make it flatter
                .padding([.leading, .trailing], 10) // Horizontal padding for internal spacing
                .frame(maxWidth: .infinity) // Ensures the box stretches to fill the available space
                .background(isSellerPriceActive ? Color.gray.opacity(0.3) : Color.black)
                .cornerRadius(5)
                .onTapGesture {
                    self.isSellerPriceActive = false
                }
            }
            .padding(.horizontal, 15) // Apply padding to the HStack to push the boxes to the edges

            
            //MARK: Interactive text box for entering a price
            ZStack(alignment: .leading) {
                TextField("Enter your bid here", text: $bidAmount)
                    .padding(.leading, 20) // Make room for the $ symbol
                    .foregroundColor(.black)
                    .keyboardType(.decimalPad)
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
    }

    private func updatePrice() {
            if let newPrice = Double(bidAmount), newPrice > 0 {
                if isSellerPriceActive {
                    sellerPrice = newPrice
                } else {
                    customerPrice = newPrice
                }
                bidAmount = "" // Clear input field after updating
            }
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

//#Preview {
//    NewBidWindow()
//}
