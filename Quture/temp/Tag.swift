import Foundation

struct Tag: Hashable, Decodable {
    var tagId: Int
    var name: String
    var category: Category
    
    enum Category: String, CaseIterable, Hashable, Decodable {
        case null = "NULL"
        case top = "Top"
        case bottom = "Bottom"
        case shoe = "Shoe"
        case accessories = "Accessories"
        case fashion = "Fashion"
    }
}
