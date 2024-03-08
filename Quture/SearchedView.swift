import SwiftUI

struct SearchedView: View {
    var searchText: String

    var body: some View {
        VStack {
            // Top bar
            HStack {
                Text("Search results for: \(searchText)")
                    .font(.title)
                    .bold()
                Spacer()
            }
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .shadow(color: .gray, radius: 2, x: 0, y: 2) // Optional: add a shadow for a raised effect

            // Rest of the content
            Spacer()
        }
        .navigationBarHidden(true) // Hide the default navigation bar
    }
}

struct SearchedView_Previews: PreviewProvider {
    static var previews: some View {
        SearchedView(searchText: "Example")
    }
}
