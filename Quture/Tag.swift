import Foundation

struct Tag: Hashable {
    var name: String
    var category: Category
    
    enum Category: String, CaseIterable, Hashable {
        case top = "Top"
        case bottom = "Bottom"
        case shoe = "Shoe"
        case accessories = "Accessories"
        case fashion = "fashion" // This is the new case you're adding
    }
} //m

 
