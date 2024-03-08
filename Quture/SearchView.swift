import SwiftUI

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = "" // State variable for the search text
    @State private var navigateToSearchedView = false // State to control navigation

    var body: some View {
        VStack {
            // Top bar
            HStack {
                TextField("Search...", text: $searchText) // Use the state variable for text binding
                    .padding(10) // Add some padding inside the TextField
                    .background(Color.white) // Set the background color of the TextField
                    .cornerRadius(10) // Round the corners of the TextField background
                    .overlay(
                        RoundedRectangle(cornerRadius: 10) // Add a rounded border
                            .stroke(Color.gray, lineWidth: 1) // Set the color and width of the border
                    )
                    .padding(.leading)
                    .onSubmit {
                        if !searchText.isEmpty {
                            navigateToSearchedView = true
                            hideKeyboard() // Dismiss the keyboard
                        }
                    }

                Spacer()

                Button("Cancel") { // Cancel button on the right
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.black)
                .padding(.trailing)
            }
            .padding(.vertical, 10)
            .background(Color.white)
            .foregroundColor(.black)

            // Horizontal bars
            ScrollView {
                VStack(spacing: 10) {
                    ForEach(0..<12, id: \.self) { index in
                        NavigationLink(destination: SearchedView(searchText: "Input \(index + 1)")) {
                            Text("Input \(index + 1)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(5)
                        }
                    }
                }
                .padding(.horizontal)
            }

            Spacer()
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(destination: SearchedView(searchText: searchText), isActive: $navigateToSearchedView) {
                EmptyView()
            }
            .hidden()
        )
    }
    
    // Function to dismiss the keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
