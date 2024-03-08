import SwiftUI
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Define FloatingTextbox component
struct FloatingTextbox: View {
    @Binding var text: String
    var title: String
    var onCommit: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(.black) // Set the title text color to black
                .padding([.top, .leading, .trailing])
            
            TextEditor(text: $text)
                .foregroundColor(.black) // Ensure the text color within the TextEditor is black
                .padding() // Apply padding for the TextEditor content
                .frame(minHeight: 100, maxHeight: 200) // Adjust based on your needs
                .background(Color.white) // Set the background color for the  TextEditor to white
                .cornerRadius(5) // Apply rounded corners to the TextEditor
        }
        .background(Color.white) // Set the background color for the entire FloatingTextbox to white
        .cornerRadius(12) // Apply rounded corners to the entire FloatingTextbox
        .shadow(radius: 10) // Add shadow for visual depth
        .padding() // Padding around the entire FloatingTextbox to separate it from other UI elements
    }
}





// Define FloatingTextboxOverlay component
struct FloatingTextboxOverlay: View {
    @Binding var isVisible: Bool
    @Binding var text: String
    var title: String
    var onCommit: () -> Void

    var body: some View {
        Color.black.opacity(0.4)
            .edgesIgnoringSafeArea(.all)
            .onTapGesture {
                isVisible = false
            }
            .overlay(
                VStack {
                    FloatingTextbox(text: $text, title: title, onCommit: onCommit)
                }
                .frame(width: UIScreen.main.bounds.width * 0.8) // Adjust width as needed
                .padding(.top, UIScreen.main.bounds.height * 0.2), // Move the overlay upwards
                alignment: .top // Align the content to the top
            )
    }
}


// DetailScreen with floating textbox overlays for caption and price inputs
struct DetailScreen: View {
    var image: UIImage
    @State var caption: String = ""
    @State var price: String = ""
    @State private var selectedCategory: Tag.Category? = nil // Exclude "Fashion" from this picker
    @State private var selectedTags: Set<Tag> = [] // For selected tags in general categories
    @State private var selectedFashionTags: Set<Tag> = [] // Specifically for "Fashion" tags
    @State private var showingCaptionInputOverlay = false
    @State private var showingPriceInputOverlay = false
    var onConfirm: ((UIImage, String, String, Set<Tag>, Set<Tag>) -> Void)? // Callback includes both sets of tags and the price
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isFieldFocused: Bool
    @FocusState private var isCaptionFocused: Bool
    @FocusState private var isPriceFocused: Bool
    
    
    // Use TagManager to get categories, excluding Fashion for the picker
    var categories: [Tag.Category] {
        Tag.Category.allCases.filter { $0 != .fashion }
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                
                // Split caption input and price input
                HStack {
                    TextField("Enter a caption...", text: $caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isCaptionFocused)
                        .onChange(of: isCaptionFocused) { isFocused in
                            showingCaptionInputOverlay = isFocused
                        }
                    Spacer()
                    // Price TextField
                    TextField("Enter a price...", text: $price)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .focused($isPriceFocused)
                        .onChange(of: isPriceFocused) { isFocused in
                            showingPriceInputOverlay = isFocused
                        }
                }
                .padding()
                
                // Fit Tags Caption
                Text("Fit Tags")
                    .font(.headline)
                    .padding(.bottom, 10)
                
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
                
                tagsScrollView(tags: TagManager.shared.tags(forCategory: .fashion), selectedTags: $selectedFashionTags)
                
                Button("Confirm") {
                    onConfirm?(image, caption, price, selectedTags, selectedFashionTags)
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.black)
                .foregroundColor(.white)
                .font(.headline)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom)
            }
            .overlay(
                Group {
                    if showingCaptionInputOverlay {
                        FloatingTextboxOverlay(isVisible: $showingCaptionInputOverlay, text: $caption, title: "Caption", onCommit: {
                            showingCaptionInputOverlay = false
                            isCaptionFocused = false // Resign focus when done
                        })
                        .transition(.move(edge: .bottom)) // Optional: Add a transition for the overlay
                    }
                    if showingPriceInputOverlay {
                        FloatingTextboxOverlay(isVisible: $showingPriceInputOverlay, text: $price, title: "Price", onCommit: {
                            showingPriceInputOverlay = false
                            isPriceFocused = false // Resign focus when done
                        })
                        .transition(.move(edge: .bottom)) // Optional: Add a transition for the overlay
                    }
                },
                alignment: .center // Center the overlay in the viewport
            )
            .padding(.top, -150) // Adjust this value to move the overlay up or down
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
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
