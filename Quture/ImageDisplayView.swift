import SwiftUI

struct ImageDisplayView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var image: UIImage
    
    var body: some View {
        VStack {
            Spacer()
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .padding()
            Spacer()
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "arrowtriangle.left.fill")
                        .font(.system(size: 20)) // Adjusted for consistency
                        .foregroundColor(.blue)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Action for search icon
                    print("Search tapped")
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 20)) // Adjusted for consistency
                }
            }
        }
        .overlay(
            HStack {
                Spacer()
                Button("Following") {
                    print("Following tapped")
                }
                .font(.title2) // Increase the font size
                .foregroundColor(.primary)

                Spacer() // These spacers push the buttons to the center

                Button("For You") {
                    print("For You tapped")
                }
                .font(.title2) // Increase the font size
                .foregroundColor(.primary)
                Spacer()
            }
            , alignment: .top
        )
        .overlay(alignment: .bottom) {
            bottomBar
        }
    }
    
    var bottomBar: some View {
        HStack {
            Button("Nearby") {
                // Action for Nearby
                print("Nearby tapped")
            }
            .font(.subheadline) // Decrease the font size
            Spacer()
            Button(action: {
                // Action for plus icon
                print("Plus tapped")
            }) {
                Image(systemName: "plus.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 26) // Reduced size
            }
            Spacer()
            Button("Profile") {
                // Action for Profile
                print("Profile tapped")
            }
            .font(.subheadline) // Decrease the font size
        }
        .padding(.vertical, 6) // Reduced padding
        .frame(maxWidth: .infinity)
        .background(Color(UIColor.systemBackground)) // Background color without shadow
    }
}

struct ImageDisplayView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ImageDisplayView(image: UIImage(named: "yourImageNameHere") ?? UIImage())
        }
    }
}
