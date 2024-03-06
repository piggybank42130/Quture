import SwiftUI
import UIKit

struct DetailScreen: View {
    var image: UIImage
    @State var caption: String
    @State private var selectedCategory: Tag.Category? = nil // For tracking selected category
    @State private var selectedTags: Set<Tag> = [] // Track selected tags
    @State private var selectedFashionTags: Set<Tag> = [] // Specifically for "Fashion" tags
    var onConfirm: ((UIImage, String, Set<Tag>) -> Void)? // Include selected tags in the callback
    @Environment(\.presentationMode) var presentationMode

    // Use TagManager to get categories
    let categories = Tag.Category.allCases

    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            
            TextField("Enter a caption...", text: $caption)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            // Category Selection
            Picker("Select Category", selection: $selectedCategory) {
                Text("None").tag(Tag.Category?.none)
                ForEach(categories, id: \.self) { category in
                    Text(category.rawValue).tag(category as Tag.Category?)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // Separate Row for "Fashion" Tags
            if selectedCategory == .fashion {
                fashionTagsSelection
            } else {
                // General Tags List for Selected Category (excluding Fashion)
                if let category = selectedCategory {
                    generalTagsList(for: category)
                }
            }

            Button("Confirm") {
                var finalSelectedTags = selectedTags
                if selectedCategory == .fashion {
                    finalSelectedTags = selectedFashionTags
                }
                onConfirm?(image, caption, finalSelectedTags)
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
    }

    // MARK: - Subviews

    private var fashionTagsSelection: some View {
        List(TagManager.shared.tags(forCategory: .fashion), id: \.self, selection: $selectedFashionTags) { tag in
            Text(tag.name).tag(tag)
        }
        .environment(\.editMode, .constant(.active))
        .frame(height: 200) // Adjust based on your UI needs
    }

    private func generalTagsList(for category: Tag.Category) -> some View {
        List(TagManager.shared.tags(forCategory: category), id: \.self, selection: $selectedTags) { tag in
            Text(tag.name).tag(tag)
        }
        .environment(\.editMode, .constant(.active))
        .frame(height: 200) // Adjust based on your UI needs
    }
}
