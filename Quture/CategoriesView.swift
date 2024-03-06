//
//  CategoriesView.swift
//  Quture
//
//  Created by Peter Zhang on 2024/3/6.
//

import SwiftUI

struct CategoriesView: View {
    let categories = Tag.Category.allCases
    @State private var selectedCategory: Tag.Category?
    
    var body: some View {
        List {
            ForEach(categories, id: \.self) { category in
                Text(category.rawValue)
                    .onTapGesture {
                        selectedCategory = category
                    }
                if selectedCategory == category {
                    ForEach(TagManager.shared.tags(forCategory: category), id: \.name) { tag in
                        Text(tag.name)
                            .padding(.leading)
                    }
                }
            }
        }
    }
}



#Preview {
    CategoriesView()
}
