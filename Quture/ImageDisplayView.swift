import SwiftUI
import Foundation

struct ImageDisplayView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showBidWindow = false // State variable for navigation
    @State private var isNewBidWindowVisible = false // New state for NewBidWindow visibility
  
    @State private var heartCount = 0
    @State private var isHeartTapped = false

    let sellerPrice: Double = 1000.00 // Dummy seller price
        let customerPrice: Double = 950.00 // Dummy customer price

    
    var imageId: Int
    var image: UIImage
    var caption: String
    var tags: [Tag]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer().frame(height: 50) // Adjust this value to move the image up
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .gesture(
                        DragGesture(minimumDistance: 50, coordinateSpace: .local)
                            .onEnded { gesture in
                                if gesture.translation.height < 0 {
                                    // Swipe up detected
                                    isNewBidWindowVisible = true
                                }
                            }
                    )
                // Caption Text Box
 
                ScrollView(.vertical, showsIndicators: true) {
                    HStack {
                        Spacer().frame(width: 20) // Add spacer to the left edge, adjust width as needed
                        Text(caption) // Replace with your dynamic caption variable
                            .font(.body) // Adjust the font size as needed
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading) // Align the text to the left
                        Spacer().frame(width: 20) // Add spacer to the right edge, adjust width as needed
                    }
                    .padding(.vertical, 10) // Add vertical padding
                }
                .frame(height: 100) // Set a fixed height for the scroll view


                
                Spacer()
            }
            
            if isNewBidWindowVisible {
                NewBidWindow(isVisible: $isNewBidWindowVisible)
                                .transition(.scale) // Transition animation for showing the overlay
                        }
            
            VStack {
                topBar
                    .padding(.top, 30) // Adjust this value to lower the top bar below the notch
                    .zIndex(1) // Ensure topBar is above other elements
                Spacer()
            }
            
            GeometryReader { geometry in
                VStack {
                    Spacer().frame(height: geometry.size.height / 2.1) // Move sidebar 2/3 down the screen
                    sidebar.padding(.horizontal, 20) // Customize sidebar size and spacing
                }
            }
            
            VStack {
                Spacer() // Push content to bottom
                bottomBar.padding(10) // Adjust padding to modify the bottom bar size
            }
        }
        
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
        .onAppear {
            
            ServerCommands().hasUserLikedImage(userId: 3, imageId: self.imageId) { has_liked, error in
                DispatchQueue.main.async {
                    if let has_liked = has_liked {
                        isHeartTapped = has_liked;
                    }  else {
                        // Handle the unexpected case where like_count is nil and there's no error
                        print(error?.localizedDescription ?? "Failed to retrieved if liked.")
                    }
                }
            }

            ServerCommands().getLikesOnImage(imageId: self.imageId) { like_count, error in
                DispatchQueue.main.async { // Ensure UI operations are on the main thread
                    if let error = error {
                        // Handle the error, e.g., log it or show an alert
                        print("Error fetching like count: \(error.localizedDescription)")
                    } else if let like_count = like_count {
                        // Safely unwrap like_count here
                        self.heartCount = like_count
                        print("Like count: \(self.heartCount)")
                    } else {
                        // Handle the unexpected case where like_count is nil and there's no error
                        print("Unexpected response: No like count and no error")
                    }
                }
            }
        }

    }
    
    
    var topBar: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .bold()
            }
            .padding(.leading, 20) // Add padding to move the icon further from the left edge
            
            Spacer()
            
            // "Following" and "For You" buttons remain centered
            HStack(spacing: 30) { // This spacing is between "Following" and "For You"
                Button("Following") {
                    print("Following tapped")
                }
                .font(.title)
                .bold()
                .foregroundColor(.white)
                
                Button("For You") {
                    print("For You tapped")
                }
                .font(.title)
                .bold()
                .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: {
                print("Search tapped")
            }) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 24))
                    .bold()
                    .foregroundColor(.white)
            }
            .padding(.trailing, 20) // Add padding to move the icon further from the right edge
        }
        .padding(.vertical, 10)
        .background(Color(UIColor.systemBackground))
    }
    
    
    var bottomBar: some View {
        Button(action: {
            // Your action when the bottom bar is tapped
            print("Bottom bar tapped")
        }) {
            HStack {
                Spacer() // Push content to center

                Image(systemName: "bookmark") // Replace with your saved image icon
                    .resizable()
                    .frame(width: 20, height: 20) // Adjust size as needed
                    .foregroundColor(.white) // Customize icon color
                
                Text("Save")
                    .font(.title) // Adjust the font size as needed
                    .bold()
                    .foregroundColor(.white) // Customize text color

                Spacer() // Push content to center
            }
            .padding() // Add padding around the HStack
            .background(Color.gray.opacity(0.2)) // Customized background color with some opacity
            .cornerRadius(10) // Rounded corners for the bottom bar
            .overlay(
                RoundedRectangle(cornerRadius: 10) // Optional: Add a border with a rounded rectangle
                    .stroke(Color.black, lineWidth: 2)
            )
        }

    }




    var sidebar: some View {
        VStack(spacing: 32) {
            Button(action: {
                ServerCommands().toggleLikeOnImage(userId: 3, imageId: imageId)
                isHeartTapped = !isHeartTapped
                heartCount += (isHeartTapped ? 1 : -1)
            }) {
                VStack {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 35))
                        .opacity(0.5)
                        .foregroundColor(isHeartTapped ? Color.pink : Color.primary)
                    Text("\(heartCount)")
                        .font(.system(size: 20))
                }
            }
            Button(action: {}) {
                Image(systemName: "bubble.right.fill")
                    .font(.system(size: 35))
                    .opacity(0.5)
            }
            Button(action: {}) {
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .font(.system(size: 35))
                    .opacity(0.5)
            }
            Button(action: {}) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 35))
                    .opacity(0.5)
            }
        }
        .padding(.trailing, 5)
        .padding(.top, 90)
        .frame(maxWidth: .infinity, alignment: .trailing)
        .foregroundColor(.primary)
    }


    
    
    
}

struct BidWindow: View {
    var body: some View {
        VStack {
            Text("Tester")
                .font(.title)
                .padding()
            Button("Close") {
                // Logic to close the overlay
            }
        }
    }
}



struct ImageDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImageDisplayView(imageId: 0, image: UIImage(named: "yourImageNameHere") ?? UIImage(), caption:"Loading...", tags: [])
        }
    }
}
