import SwiftUI

struct PostPageView: View {
    var image: UIImage // The selected image to display
    
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack {
            Spacer(minLength: 20) // Adjust the spacer to lower the top bar if needed
            
            // Top Bar
            HStack {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss() // Dismiss PostPageView
                }) {
                    Image(systemName: "chevron.left") // Back icon
                        .foregroundColor(.black)
                        .imageScale(.large)
                        .padding()
                }

                Spacer()

                Button("Following") {
                    // Action for "Following"
                }

                Spacer()

                Button("For You") {
                    // Action for "For You"
                }

                Spacer()

                Image(systemName: "magnifyingglass") // Search icon
                    .foregroundColor(.black)
                    .imageScale(.large)
                    .padding()
            }
            .padding([.top, .bottom], 10)
            
            Spacer()
            
            // Middle Section: Display the selected image
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            Spacer()
            
            // Bottom Bar
            HStack {
                Text("Nearby")
                    .padding()

                Spacer()

                Image(systemName: "plus.circle.fill") // Plus icon
                    .foregroundColor(.black)
                    .imageScale(.large)
                    .padding()

                Spacer()

                Text("Profile")
                    .padding()
            }
            .padding(.top, 10)
        }
        .background(Color.green)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // Optional, depending on your navigation configuration
    }
}
