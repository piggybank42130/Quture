import SwiftUI

struct ImageDisplayView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var showBidWindow = false // State variable for navigation
    
    
    var image: UIImage
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .gesture(
                        DragGesture(minimumDistance: 50, coordinateSpace: .local)
                            .onEnded { gesture in
                                if gesture.translation.height < 0 {
                                    // Swipe up detected
                                    showBidWindow = true
                                }
                            }
                    )
                Spacer()
            }
            
            if showBidWindow {
                // Overlay window in the middle of the screen
                BidWindow()
                    .frame(width: 300, height: 150) // Customize the size as needed
                    .background(Color.white) // Customize the background color
                    .cornerRadius(20) // Rounded corners
                    .shadow(radius: 10) // Shadow for better visibility
                    .transition(.scale) // Transition animation for showing the overlay
                    .onTapGesture {
                        showBidWindow = false // Hide the overlay when tapped
                    }
            }
            
            VStack {
                topBar
                    .padding(.top, 30) // Adjust this value to lower the top bar below the notch
                    .zIndex(1) // Ensure topBar is above other elements
                Spacer()
            }
            
            GeometryReader { geometry in
                VStack {
                    Spacer().frame(height: geometry.size.height / 2) // Move sidebar 2/3 down the screen
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
        HStack {
            Button("Nearby") {
                print("Nearby tapped")
            }
            .font(.title) // Slightly smaller font size compared to .title
            .foregroundColor(.white) // Customize text color
            .padding(.vertical, 10) // Customize padding around the text for a tighter fit
            .bold()
            
            Spacer()
            
            Button(action: {
                print("Plus tapped")
            }) {
                Image(systemName: "plus.square") // Square plus icon
                    .resizable()
                    .frame(width: 40, height: 40) // Make the icon smaller
                    .foregroundColor(.white) // Customize icon color
                    .bold()
                
            }
            
            Spacer()
            
            Button("Profile") {
                print("Profile tapped")
            }
            .font(.title) // Slightly smaller font size compared to .title
            .bold()
            .foregroundColor(.white) // Customize text color
            .padding(.vertical, 10) // Customize padding around the text for a tighter fit
        }
        .padding(.horizontal) // Custom horizontal padding for the whole bar
        .padding(.vertical, 12) // Custom vertical padding for the whole bar
        .background(Color.gray.opacity(0.2)) // Customized background color with some opacity
        .cornerRadius(10) // Rounded corners for the bottom bar
        .overlay(
            RoundedRectangle(cornerRadius: 10) // Optional: Add a border with a rounded rectangle
                .stroke(Color.black, lineWidth: 2)
        )
        .padding(.bottom, 10) // Ensure there's some space between the bottom bar and the screen's bottom edge
    }
    
    
    var sidebar: some View {
        VStack(spacing: 32) { // Slightly increased spacing between icons
            Button(action: { print("Heart tapped") }) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 35)) // Keep the bigger icon size
                    .opacity(0.5) // Make icons more transparent
            }
            
            Button(action: { print("Comment tapped") }) {
                Image(systemName: "bubble.right.fill")
                    .font(.system(size: 35)) // Keep the bigger icon size
                    .opacity(0.5) // Make icons more transparent
            }
            
            Button(action: { print("Forward tapped") }) {
                Image(systemName: "arrowshape.turn.up.right.fill")
                    .font(.system(size: 35)) // Keep the bigger icon size
                    .opacity(0.5) // Make icons more transparent
            }
            
            Button(action: { print("More tapped") }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 35)) // Keep the bigger icon size
                    .opacity(0.5) // Make icons more transparent
            }
        }
        .padding(.trailing, 5) // Reduce padding to bring it closer to the edge
        .padding(.top, 90) // Adjust this value to position the sidebar higher
        .frame(maxWidth: .infinity, alignment: .trailing) // Ensure alignment to the right
        .foregroundColor(.primary) // Use the primary color for the icons
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
            ImageDisplayView(image: UIImage(named: "yourImageNameHere") ?? UIImage())
        }
    }
}
