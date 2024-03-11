import Foundation

class TagManager {
    static let shared = TagManager()
    
    private(set) var tags: [Tag] = [
        // Top tags
        Tag(tagId: 1, name: "Athletic", category: .top),
        Tag(tagId: 2, name: "Blouse", category: .top),
        Tag(tagId: 3, name: "Buttonup", category: .top),
        Tag(tagId: 4, name: "Casual", category: .top),
        Tag(tagId: 5, name: "Crewneck", category: .top),
        Tag(tagId: 6, name: "Hoodie", category: .top),
        Tag(tagId: 7, name: "Jacket", category: .top),
        Tag(tagId: 8, name: "Suit", category: .top),
        Tag(tagId: 9, name: "Sweater", category: .top),
        Tag(tagId: 10, name: "T-shirt", category: .top),
        Tag(tagId: 11, name: "Top", category: .top),
        Tag(tagId: 12, name: "Vintage", category: .top),
        Tag(tagId: 13, name: "Workwear", category: .top),
        
        // Bottom tags - Adjusting IDs due to insertion
        Tag(tagId: 14, name: "Athletic", category: .bottom),
        Tag(tagId: 15, name: "Bottom", category: .bottom),
        Tag(tagId: 16, name: "Cargo", category: .bottom),
        Tag(tagId: 17, name: "Dress", category: .bottom),
        Tag(tagId: 18, name: "Dress pants", category: .bottom),
        Tag(tagId: 19, name: "Fitted", category: .bottom),
        Tag(tagId: 20, name: "Jeans", category: .bottom),
        Tag(tagId: 21, name: "Pants", category: .bottom),
        Tag(tagId: 22, name: "Parachute", category: .bottom),
        Tag(tagId: 23, name: "Shorts", category: .bottom),
        Tag(tagId: 24, name: "Skirt", category: .bottom),
        Tag(tagId: 25, name: "Vintage", category: .bottom),
        
        // Shoe tags - Adjusting IDs due to insertion
        Tag(tagId: 26, name: "Boots", category: .shoe),
        Tag(tagId: 27, name: "Customs", category: .shoe),
        Tag(tagId: 28, name: "Dress shoes", category: .shoe),
        Tag(tagId: 29, name: "Loafers", category: .shoe),
        Tag(tagId: 30, name: "Sandals", category: .shoe),
        Tag(tagId: 31, name: "Shoe", category: .shoe),
        Tag(tagId: 32, name: "Sneakers", category: .shoe),
        
        // Accessories tags - Adjusting IDs due to insertion
        Tag(tagId: 33, name: "Accessories", category:.accessories),
        Tag(tagId: 34, name: "Ear ring", category: .accessories),
        Tag(tagId: 35, name: "Glasses", category: .accessories),
        Tag(tagId: 36, name: "Hat", category: .accessories),
        Tag(tagId: 37, name: "Necklace", category: .accessories),
        Tag(tagId: 38, name: "Ring", category: .accessories),
        
        // Fashion tags - Adjusting IDs due to insertion
        Tag(tagId: 39, name: "Archive", category: .fashion),
        Tag(tagId: 40, name: "Athleisure", category: .fashion),
        Tag(tagId: 41, name: "Avant-Garde", category: .fashion),
        Tag(tagId: 42, name: "Customs", category: .fashion),
        Tag(tagId: 43, name: "Denim", category: .fashion),
        Tag(tagId: 44, name: "Fashion", category: .fashion),
        Tag(tagId: 45, name: "Minimalism", category: .fashion),
        Tag(tagId: 46, name: "Preppy", category: .fashion),
        Tag(tagId: 47, name: "Streetwear", category: .fashion),
        Tag(tagId: 48, name: "Techwear", category: .fashion)
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
    
    func getAllTagNames() -> [String] {
        return tags.filter { $0.name != "NULL" }.map { $0.name }
    }
    
    func getTagIdsByCategory(category: Tag.Category) -> [Int] {
        return tags.filter { $0.category == category }.map { $0.tagId }
    }
    
    func getNull() -> Tag{
        return Tag(tagId: -1, name: "NULL", category: .null)
    }

} //m
