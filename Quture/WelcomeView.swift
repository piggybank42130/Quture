import SwiftUI

struct WelcomeView: View {
    var dismissAction: () -> Void
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors
    
    var body: some View {
        ZStack {
            // Background for fireworks effect to make it more prominent
            Color.black.opacity(0.4).edgesIgnoringSafeArea(.all)
            
            // Main content of the overlay
            VStack(spacing: 40) {
                Spacer()
                
                Text("Welcome to the QUTURE, USER!")
                    .font(.headline)
                    .foregroundColor(.primary) // Use .primary for automatic light/dark mode adjustment
                
                Image(colorScheme == .dark ? "POPUPDARK" : "POPUPLIGHT")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 200)
                
                Text("Check out what's new today.")
                    .font(.subheadline)
                    .foregroundColor(.primary) // Use .primary here as well
                
                Spacer()
            }
            .frame(width: 300, height: 500) // Adjust the frame size as needed
            .background(Color(.systemBackground)) // Adjusts for light/dark mode
            .cornerRadius(12)
            .shadow(radius: 8)
            
            
            // Firework Effect, positioned above everything
            FireworkEffectView()
                .frame(width: 360, height: 360)
                .position(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 2 - 150) // Center the firework effect
                .zIndex(2)
            
            // Dismiss button placed in the top right corner, partially outside the overlay
            Button(action: dismissAction) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(Color.contrastColor(for: colorScheme))
                    .imageScale(.large)
                    .background(Color(.systemBackground).cornerRadius(15)) // Ensures the background adjusts for light/dark mode
                    .clipShape(Circle())
                    .shadow(radius: 2)
            }
            .offset(x: 150, y: -250) // Adjust these values as needed to place the button correctly
            
        }
    }
}

// Preview provider
struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView(dismissAction: {})
            .preferredColorScheme(.dark) // Add this line to test in dark mode
    }
}
