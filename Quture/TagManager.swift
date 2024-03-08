import Foundation

class TagManager {
    static let shared = TagManager()
    
    private(set) var tags: [Tag] = [
        // Initialize with your default tags

        //Top tag
        Tag(name: "Suit", category: .top),
        Tag(name: "Buttonup", category: .top),
        Tag(name: "Sweater", category: .top),
        Tag(name: "T-shirt", category: .top),
        Tag(name: "Athletic", category: .top),
        Tag(name: "Crewneck", category: .top),
        Tag(name: "Jacket", category: .top),
        Tag(name: "Workwear", category: .top),
        Tag(name: "Casual", category: .top),
        Tag(name: "Vintage", category: .top),
        //Tottom tag
        Tag(name: "Dress pants", category: .bottom),
        Tag(name: "Jeans", category: .bottom),
        Tag(name: "Parachute", category: .bottom),
        Tag(name: "Athletic", category: .bottom),
        Tag(name: "Cargo", category: .bottom),
        Tag(name: "Fitted", category: .bottom),
        Tag(name: "Vintage", category: .bottom),
        //Shoe tag
        Tag(name: "Boots", category: .shoe),
        Tag(name: "Loafers", category: .shoe),
        Tag(name: "Sneakers", category: .shoe),
        Tag(name: "Dress shoes", category: .shoe),
        Tag(name: "Sandals", category: .shoe),
        Tag(name: "Customs", category: .shoe),
        //Accessories tag
        Tag(name: "Necklace", category: .accessories),
        Tag(name: "Ear ring", category: .accessories),
        Tag(name: "Ring", category: .accessories),
        Tag(name: "Glasses", category: .accessories),
        //Fasion tag
        Tag(name: "Minimalism", category: .fashion),
        Tag(name: "Techwear", category: .fashion),
        Tag(name: "Avant-Garde", category: .fashion),
        Tag(name: "Preppy", category: .fashion),
        Tag(name: "Customs", category: .fashion),
        Tag(name: "Denim", category: .fashion),
        Tag(name: "Athleisure", category: .fashion),
        Tag(name: "Archive", category: .fashion),      
    ]
     
    func addTag(_ tag: Tag) {
        tags.append(tag)
    }
    
    func tags(forCategory category: Tag.Category) -> [Tag] {
        tags.filter { $0.category == category }
    }
} //m
