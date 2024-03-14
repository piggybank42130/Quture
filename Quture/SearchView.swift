import SwiftUI

struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var searchText = "" // State variable for the search text
    @State private var navigateToSearchedView = false // State to control navigation
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors
    @State private var isMatchFound = false
    @State private var matchingTagNames: [String] = []
    @State private var searchDebounceTimer: Timer?

    var body: some View {
        VStack {
            //Search Bar
            searchTopBar
            
            if isMatchFound && !matchingTagNames.isEmpty{
                searchResultsView
            }
            else{
                Spacer()
            }
        }
        .navigationBarHidden(true)
        .background(
            NavigationLink(destination: SearchedView(searchText: searchText), isActive: $navigateToSearchedView) {
                EmptyView()
            }
            .hidden()
        )
    }
    
    private var searchTopBar: some View{
        HStack {
            TextField("Search...", text: $searchText)
                .onChange(of: searchText) { newValue in
                                    searchDebounced(text: newValue)
                }
                .padding(10)
                .background(Color.sameColor(forScheme: colorScheme))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray, lineWidth: 1)
                )
                .padding(.leading)

            Spacer()

            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            .foregroundColor(Color.contrastColor(for: colorScheme))
            .padding(.trailing)
        }
        .padding(.vertical, 10)
        .background(Color.sameColor(forScheme: colorScheme))
        .foregroundColor(.contrastColor(for: colorScheme))
    }
    
    private var searchResultsView: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(matchingTagNames, id: \.self) { tagName in
                    NavigationLink(destination: SearchedView(searchText: tagName)) {
                        Text(tagName)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    // Function to dismiss the keyboard
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    private func searchDebounced(text: String) {
            searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                Task {
                    await searchForTags()
                }
            }
        }
    
    // Function to check if search term matches any tags
    private func doesSearchTermMatchAnyTag(searchTerm: String) -> Bool {
        let lowercaseSearchTerm = searchTerm.lowercased()
        return TagManager.shared.tags.contains { tag in
            tag.name.lowercased().contains(lowercaseSearchTerm)
        }
    }
    
    private func searchForTags() async {
        print("Searching for tags with searchTerm: \(searchText)")
        do {
            print("Fetching tags")
            let tagIds = try await ServerCommands().searchTags(searchTerm: searchText)
            print(tagIds)
            let tagNames = tagIds.compactMap { TagManager.shared.getTagById(tagId: $0)?.name }
            print(tagNames)
            DispatchQueue.main.async {
                self.matchingTagNames = tagNames
                self.isMatchFound = !tagNames.isEmpty
            }
        } catch {
            print("")
            DispatchQueue.main.async {
                self.isMatchFound = false
                self.matchingTagNames = []
            }
        }
    }
}
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
