import SwiftUI

struct VisualStudioView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 0) {
            topBar // Custom top bar
            Spacer() // The rest of your view content will go here
        }
        .navigationBarHidden(true) // Ensure SwiftUI doesn't show its default Navigation Bar
        .gesture(
            DragGesture().onEnded { value in
                // Check for a horizontal drag that is more to the right than down/up
                if value.translation.width > 100 && abs(value.translation.height) < abs(value.translation.width) {
                    self.presentationMode.wrappedValue.dismiss()
                }
            }
        )
    }
    
    var topBar: some View {
        HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss() // Action to dismiss the current view
            }) {
                Image(systemName: "arrowtriangle.left.fill") // Triangle-shaped back button
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(.leading, 20) // Add padding to move the icon further from the left edge
            }
            
            Spacer()
            
            Text("Save") // Center-aligned text
                .font(.title)
                .bold()
                .foregroundColor(.white)
            
            Spacer()
            
            // This is a placeholder to balance the 'Save' text in the center.
            // It's invisible but takes the same space as the back button for symmetry.
            Image(systemName: "arrowtriangle.left.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .padding(.leading, 20)
                .opacity(0) // Make it invisible
        }
        .padding(.vertical, 10)
        .background(Color.blue) // Set your desired background color here
    }
}

// This part should be outside any struct or class declaration
extension CGFloat {
    var abs: CGFloat {
        return Swift.abs(self)
    }
}

struct VisualStudioView_Previews: PreviewProvider {
    static var previews: some View {
        VisualStudioView()
    }
}
