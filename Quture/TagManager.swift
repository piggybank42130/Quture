import Foundation

class TagManager {
    static let shared = TagManager()
    
    private(set) var tags: [Tag] = [
        // Initialize with your default tags

        // Top tag
        Tag(tagId: -1, name: "NULL", category: .null),
        Tag(tagId: 1, name: "Suit", category: .top),
        Tag(tagId: 2, name: "Buttonup", category: .top),
        Tag(tagId: 3, name: "Sweater", category: .top),
        Tag(tagId: 4, name: "T-shirt", category: .top),
        Tag(tagId: 5, name: "Athletic", category: .top),
        Tag(tagId: 6, name: "Crewneck", category: .top),
        Tag(tagId: 7, name: "Jacket", category: .top),
        Tag(tagId: 8, name: "Workwear", category: .top),
        Tag(tagId: 9, name: "Casual", category: .top),
        Tag(tagId: 10, name: "Vintage", category: .top),
        // Bottom tag
        Tag(tagId: 11, name: "Dress pants", category: .bottom),
        Tag(tagId: 12, name: "Jeans", category: .bottom),
        Tag(tagId: 13, name: "Parachute", category: .bottom),
        Tag(tagId: 14, name: "Athletic", category: .bottom),
        Tag(tagId: 15, name: "Cargo", category: .bottom),
        Tag(tagId: 16, name: "Fitted", category: .bottom),
        Tag(tagId: 17, name: "Vintage", category: .bottom),
        // Shoe tag
        Tag(tagId: 18, name: "Boots", category: .shoe),
        Tag(tagId: 19, name: "Loafers", category: .shoe),
        Tag(tagId: 20, name: "Sneakers", category: .shoe),
        Tag(tagId: 21, name: "Dress shoes", category: .shoe),
        Tag(tagId: 22, name: "Sandals", category: .shoe),
        Tag(tagId: 23, name: "Customs", category: .shoe),
        // Accessories tag
        Tag(tagId: 24, name: "Necklace", category: .accessories),
        Tag(tagId: 25, name: "Ear ring", category: .accessories),
        Tag(tagId: 26, name: "Ring", category: .accessories),
        Tag(tagId: 27, name: "Glasses", category: .accessories),
        // Fashion tag
        Tag(tagId: 28, name: "Minimalism", category: .fashion),
        Tag(tagId: 29, name: "Techwear", category: .fashion),
        Tag(tagId: 30, name: "Avant-Garde", category: .fashion),
        Tag(tagId: 31, name: "Preppy", category: .fashion),
        Tag(tagId: 32, name: "Customs", category: .fashion),
        Tag(tagId: 33, name: "Denim", category: .fashion),
        Tag(tagId: 34, name: "Athleisure", category: .fashion),
        Tag(tagId: 35, name: "Archive", category: .fashion)
    ]
     
    func addTag(_ tag: Tag) {
        tags.append(tag)
    }
    
    func getTagsByCategory(forCategory category: Tag.Category) -> [Tag] {
        tags.filter { $0.category == category }
    }
    
    func getTagByName(byName name: String) -> Tag? {
        tags.first { $0.name.lowercased() == name.lowercased() }
    }
    
    func getTagById(tagId: Int) -> Tag? {
        return tags.first { $0.tagId == tagId }
    }
    
    func getNull() -> Tag{
        return Tag(tagId: -1, name: "NULL", category: .null)
    }

} //m
