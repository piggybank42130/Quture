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
    @Environment(\.colorScheme) var colorScheme // light and dark mode colors
    
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color.contrastColor(for: colorScheme)) // Set the title text color to black
                .padding([.top, .leading, .trailing])
            
            TextEditor(text: $text)
                .foregroundColor(Color.contrastColor(for: colorScheme)) // Ensure the text color within the TextEditor is black
                .padding() // Apply padding for the TextEditor content
                .frame(minHeight: 100, maxHeight: 200) // Adjust based on your needs
                .background(Color.sameColor(forScheme: colorScheme)) // Set the background color for the  TextEditor to white
                .cornerRadius(5) // Apply rounded corners to the TextEditor
        }
        .background(Color.sameColor(forScheme: colorScheme)) // Set the background color for the entire FloatingTextbox to white
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

extension String {
    func containsMultipleDecimalPoints() -> Bool {
        let decimalPoints = self.filter { $0 == "." }
        return decimalPoints.count > 1
    }
}

// DetailScreen with floating textbox overlays for caption and price inputs
struct DetailScreen: View {
    var image: UIImage
    @State var caption: String = ""
    @State var price: String = ""
    @State private var selectedCategory: Tag.Category? = nil
    @State private var selectedTags: Set<Tag> = []
    @State private var selectedFashionTags: Set<Tag> = []
    @State private var showingCaptionInputOverlay = false
    @State private var showingPriceInputOverlay = false
    var onConfirm: ((UIImage, String, String, Set<Tag>, Set<Tag>) -> Void)?
    @Environment(\.presentationMode) var presentationMode
    @FocusState private var isFieldFocused: Bool
    @FocusState private var isCaptionFocused: Bool
    @FocusState private var isPriceFocused: Bool
    @Environment(\.colorScheme) var colorScheme
    @State private var showAlert = false
    @State private var showAlertForPrice = false
    @State private var alertMessage = ""
    @State private var hasSelectedRequiredTags = false


  
    
    var categories: [Tag.Category] {
        Tag.Category.allCases.filter { $0 != .fashion && $0 != .null }
    }

    
    var body: some View {
        ScrollView {
            VStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                
                HStack {
                    TextField("Caption", text: $caption)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isCaptionFocused)
                        .onChange(of: isCaptionFocused) { isFocused in
                            showingCaptionInputOverlay = isFocused
                        }
                    Spacer()
                    TextField("(Optional) Price", text: $price)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                        .focused($isPriceFocused)
                        .onChange(of: isPriceFocused) { isFocused in
                            showingPriceInputOverlay = isFocused
                        }
                }
                .padding()
                
                Text("Fit Tags")
                    .font(.headline)
                    .padding(.bottom, 10)
                
                HStack {
                    ForEach(categories, id: \.self) { category in
                        Button(action: {
                            self.selectedCategory = category
                        }) {
                            Text(category.rawValue)
                                .font(.system(size: 16)) // Adjust the font size as needed to prevent wrapping
                                .foregroundColor(selectedCategory == category ? .white : (colorScheme == .dark ? .white : .black))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12) // Adjust padding to ensure buttons have enough space
                                .background(selectedCategory == category ? (colorScheme == .dark ? Color.gray : Color.black) : Color.gray.opacity(0.2)) // Adjust highlight color based on theme
                                .cornerRadius(8)
                        }
                        .buttonStyle(PlainButtonStyle()) // Use PlainButtonStyle to avoid button's default styling effects
                    }
                }
                .padding()
                .background(Color.sameColor(forScheme: colorScheme)) // This sets the background of the HStack container
                .cornerRadius(8)
                
                if let category = selectedCategory, category != .fashion {
                    tagsScrollView(tags: TagManager.shared.getTagsByCategory(forCategory: category), selectedTags: $selectedTags)
                }
                
                Text("Fashion Tags")
                    .font(.headline)
                    .padding(.top, 10)
                
                tagsScrollView(tags: TagManager.shared.getTagsByCategory(forCategory: .fashion), selectedTags: $selectedFashionTags)
                
                Button("Confirm") {
                    if caption.isEmpty {
                        alertMessage = "Please describe your post with what you are selling."
                        showAlert = true
                    } else if let priceValue = Double(price), priceValue > 10_000 {
                        alertMessage = "Price cannot exceed 10,000."
                        showAlert = true
                    } else if price.containsMultipleDecimalPoints() {
                        alertMessage = "Price cannot contain multiple decimal points."
                        showAlert = true
                    } else if selectedTags.isEmpty || selectedFashionTags.isEmpty {
                        alertMessage = "Please select at least one tag from each required category."
                        showAlert = true
                    } else {
                        onConfirm?(image, caption, price, selectedTags, selectedFashionTags)
                        presentationMode.wrappedValue.dismiss()
                    }
                }

                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.sameColor(forScheme: colorScheme))
                .foregroundColor(Color.contrastColor(for: colorScheme))
                .font(.headline)
                .cornerRadius(10)
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .padding(.top, 15) // Added padding at the top of the ScrollView
        .edgesIgnoringSafeArea(.bottom)
        .gesture(
            TapGesture()
                .onEnded{ _ in
                    UIApplication.shared.endEditing()
                }
        )
        .overlay(
            Group {
                if showingCaptionInputOverlay {
                    FloatingTextboxOverlay(isVisible: $showingCaptionInputOverlay, text: $caption, title: "Caption", onCommit: {})
                }
                if showingPriceInputOverlay {
                    FloatingTextboxOverlay(isVisible: $showingPriceInputOverlay, text: $price, title: "Price", onCommit: {})
                }
            }
        )
        .alert(isPresented: $showAlert) {
            Alert(
                    title: Text("Error"),
                    message: Text(alertMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
        
    }

    
    
    func tagsScrollView(tags: [Tag], selectedTags: Binding<Set<Tag>>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(tags, id: \.self) { tag in
                    let isSelected = selectedTags.wrappedValue.contains(tag)
                    let backgroundColor = isSelected ? Color.DarkGray : Color.gray.opacity(0.2)

                    Text(tag.name)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(backgroundColor)
                        .foregroundColor(Color.contrastColor(for: colorScheme))
                        .clipShape(Capsule())
                        .font(.caption)
                        .onTapGesture {
                            updateSelectedTags(tag: tag, selectedTags: selectedTags)
                        }
                }
            }
        }
        .padding()
    }

    func updateSelectedRequiredTags(selectedTags: Set<Tag>, selectedFashionTags: Set<Tag>) {
        let categoriesToCheck: [Tag.Category] = [.top, .bottom, .shoe, .accessories]
        let hasRequiredCategoryTag = categoriesToCheck.contains { category in
            selectedTags.contains { tag in
                tag.category == category
            }
        }
        hasSelectedRequiredTags = hasRequiredCategoryTag && !selectedFashionTags.isEmpty
    }


    func updateSelectedTags(tag: Tag, selectedTags: Binding<Set<Tag>>) {
        if selectedTags.wrappedValue.contains(tag) {
            selectedTags.wrappedValue.remove(tag)
        } else {
            selectedTags.wrappedValue.insert(tag)
        }
        // Update hasSelectedRequiredTags based on the current selection
        updateSelectedRequiredTags(selectedTags: selectedTags.wrappedValue, selectedFashionTags: selectedFashionTags)
    }

}

// Assuming TagManager and Tag definitions are as previously defined
