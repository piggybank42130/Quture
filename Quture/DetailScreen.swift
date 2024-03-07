import SwiftUI
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}


struct DetailScreen: View {
    var image: UIImage
    @State var caption: String = ""
    @State var price: String = ""
    @State private var selectedCategory: Tag.Category? = nil // Exclude "Fashion" from this picker
    @State private var selectedTags: Set<Tag> = [] // For selected tags in general categories
    @State private var selectedFashionTags: Set<Tag> = [] // Specifically for "Fashion" tags
    var onConfirm: ((UIImage, String, String, Set<Tag>, Set<Tag>) -> Void)? // Callback includes both sets of tags and the price
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isFieldFocused: Bool
    
    
    // Use TagManager to get categories, excluding Fashion for the picker
    var categories: [Tag.Category] {
        Tag.Category.allCases.filter { $0 != .fashion }
    }
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
            
            // Split caption input and price input
            HStack {
                TextField("Enter a caption...", text: $caption)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isFieldFocused)
                
                Spacer()
                
                TextField("Enter a price...", text: $price)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .focused($isFieldFocused)
                
                
            }
            .padding()
            
            // Fit Tags Caption
            Text("Fit Tags")
                .font(.headline)
                .padding(.bottom, -10)
            
            // Category Selection Picker, excluding Fashion
            Picker("Select Category", selection: $selectedCategory) {
                ForEach(categories, id: \.self) { category in
                    Text(category.rawValue).tag(category as Tag.Category?)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // Tags ScrollView for the selected category, excluding Fashion
            if let category = selectedCategory, category != .fashion {
                tagsScrollView(tags: TagManager.shared.tags(forCategory: category), selectedTags: $selectedTags)
            }
            
            // Separate Scrollable View for "Fashion" Tags
            Text("Fashion Tags")
                .font(.headline)
                .padding(.top, 10)
                .padding(.bottom, -10)
            tagsScrollView(tags: TagManager.shared.tags(forCategory: .fashion), selectedTags: $selectedFashionTags)
            
            Button("Confirm") {
                onConfirm?(image, caption, price, selectedTags, selectedFashionTags)
                presentationMode.wrappedValue.dismiss()
            }
            .padding() // Add padding around the text for a better touch area
            .frame(maxWidth: .infinity) // Make the button expand to fill the available space
            .background(Color.black) // Set the background color to black
            .foregroundColor(.white) // Set the text color to white
            .font(.headline) // Increase the font size to headline
            .cornerRadius(10) // Optional: Add a corner radius to soften the button edges
            .padding(.horizontal) // Add horizontal padding to not stick to the screen edges
            .padding(.bottom) // Add some padding at the bottom to ensure it's not flush with the screen edge
        }
        .edgesIgnoringSafeArea(.bottom)

    }
    
    // Reusable ScrollView for tags, used for both general and fashion tags, with smaller capsules
//    func tagsScrollView(tags: [Tag], selectedTags: Binding<Set<Tag>>) -> some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ForEach(tags, id: \.self) { tag in
//                    Text(tag.name)
//                        .padding(.vertical, 6) // Smaller vertical padding
//                        .padding(.horizontal, 12) // Smaller horizontal padding
//                        .background(selectedTags.wrappedValue.contains(tag) ? Color.blue : Color.gray.opacity(0.2))
//                        .foregroundColor(Color.white)
//                        .clipShape(Capsule())
//                        .font(.caption) // Smaller font size
//                        .onTapGesture {
//                            if selectedTags.wrappedValue.contains(tag) {
//                                selectedTags.wrappedValue.remove(tag)
//                            } else {
//                                selectedTags.wrappedValue.insert(tag)
//                            }
//                        }
//                }
//            }
//        }
//        .padding(.vertical, 10)
//    }
    func tagsScrollView(tags: [Tag], selectedTags: Binding<Set<Tag>>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    Text(tag.name)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(selectedTags.wrappedValue.contains(tag) ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                        .font(.caption)
                        .onTapGesture {
                            // Check if tapping should select a category instead
                            if let tagCategory = Tag.Category(rawValue: tag.name.lowercased()), categories.contains(tagCategory) {
                                self.selectedCategory = tagCategory
                            } else {
                                if selectedTags.wrappedValue.contains(tag) {
                                    selectedTags.wrappedValue.remove(tag)
                                } else {
                                    selectedTags.wrappedValue.insert(tag)
                                }
                            }
                        }
                }
            }
        }
        .padding()
    }
}

// Assuming TagManager and Tag definitions are as previously defined
