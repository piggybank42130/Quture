import SwiftUI

struct VisualStudioView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    
    let rectangles: [RectangleContent] = Array(repeating: RectangleContent(image: UIImage(systemName: "photo"), caption: "Sample"), count: 20)
 
    var body: some View {
            VStack(spacing: 0) {
                topBar // Custom top bar
                // Horizontal ScrollView for sheets
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack(spacing: LayoutConfig.spacing) {
                        ForEach(0..<rectangles.count, id: \.self) { index in
                            RectangleView(content: rectangles[index])
                                .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight) // Adjust size as needed
                        }
                    }
                }
                Spacer()
            }
            .navigationBarHidden(true)
            .gesture(
                DragGesture().onEnded { value in
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

struct RectangleView: View {
    let content: RectangleContent

        var body: some View {
               VStack {
                   Rectangle()
                       .fill(Color.gray) // Display a gray rectangle
                       .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight) // Use predefined sizes
                   Text(content.caption)
                       .foregroundColor(.white) // Set text color to ensure it's visible on gray background
               }
        .background(Color.gray) // Sets the background of each rectangle to gray
        .frame(width: LayoutConfig.rectangleWidth, height: LayoutConfig.rectangleHeight)
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
