import SwiftUI

struct BidWindowView: View {
    var image: UIImage
    
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
            Spacer()
            
            Text("Save")
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Spacer()
        }
        .padding()
        .background(Color.black.opacity(0.8))
    }
}
