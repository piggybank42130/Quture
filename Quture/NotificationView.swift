import SwiftUI

struct NotificationView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View {
        VStack {
            // Your notifications content...
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: HStack {
            Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "arrowtriangle.left.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white) // Adjust the color to match your app's theme
            }
            
            Spacer() // Push content to center
            
            Text("Notifications")
                .font(.title)
                .bold()
                .foregroundColor(.white) // Adjust the color to match your app's theme
            
            Spacer() // Push content to center
            
            // Invisible image for symmetry
            Image(systemName: "arrowtriangle.left.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
                .opacity(0) // Make it invisible
        })
    }
}

struct NotificationsView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView()
    }
}
