import SwiftUI

struct BidWindowView: View {
    var image: UIImage
    @State private var highestBid: String = ""
    let buyNowPrice: String = "100" // Example fixed price for "Buy Now"
    @State private var showAlert: Bool = false

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                Spacer()
            }
            
            VStack {
                topBar.padding(.top, 30)
                Spacer()
            }

            VStack {
                Spacer()
                bottomBar.padding(10)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Cannot Change Set Price"),
                message: Text("Try input price"),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    var topBar: some View {
        HStack {
            Text("Bid")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.8))
    }
    
    var bottomBar: some View {
        HStack {
            // Highest Bid text box
            TextField("Highest Bid", text: $highestBid)
                .font(.title)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .keyboardType(.numberPad)
            
            Spacer()
            
            // Buy Now price display (non-editable)
            Text("Buy Now: $\(buyNowPrice)")
                .font(.title)
                .bold()
                .foregroundColor(.white)
                .padding()
            
            Spacer()
            
            // Confirm button
            Button(action: {
                showAlert = true
            }) {
                Text("Confirm")
                    .font(.title)
                    .bold()
                    .foregroundColor(.white)
                    .padding()
            }
        }
        .padding()
        .background(Color.black.opacity(0.8))
    }
}

struct BidWindowView_Previews: PreviewProvider {
    static var previews: some View {
        BidWindowView(image: UIImage(named: "sampleImage") ?? UIImage())
    }
}
