import SwiftUI

struct DynamicImageGridItem: Identifiable {
    let id = UUID()
    var content: RectangleContent // Now holding RectangleContent
    var column: Int
    var yOffset: CGFloat
}

struct DynamicImageGridView: View {
    @State private var selectedContent: RectangleContent?

    var contents: [RectangleContent] // Your rectangle contents
    @Binding var isCaptionShown: Bool

    private let columns: Int = 2
    private let horizontalSpacing: CGFloat = 10 // Spacing between columns
    private let verticalSpacing: CGFloat = 10 // Spacing between rows
    private let topPadding: CGFloat = 15 // Padding at the top of the grid
    private let contentIndex: Int? = nil // Padding at the top of the grid

    var onImageTap: (RectangleContent) -> Void

    
    
    private func calculateGridItems() -> [DynamicImageGridItem] {
        var items = [DynamicImageGridItem]()
        var yOffset: [CGFloat] = .init(repeating: topPadding, count: columns)
        
        for content in contents {
            if let image = content.image {
                let aspectRatio = image.size.width / image.size.height
                let columnWidth = (UIScreen.main.bounds.width - (horizontalSpacing * CGFloat(columns - 1))) / CGFloat(columns)
                let imageHeight = columnWidth / aspectRatio
                
                let shortestColumnIndex = yOffset.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
                let item = DynamicImageGridItem(content: content, column: shortestColumnIndex, yOffset: yOffset[shortestColumnIndex])
                items.append(item)
                yOffset[shortestColumnIndex] += imageHeight + verticalSpacing
            }
        }
        return items
    }

    private func columnWidth(in totalWidth: CGFloat) -> CGFloat {
        (totalWidth - (horizontalSpacing * CGFloat(columns - 1))) / CGFloat(columns)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                let width = columnWidth(in: geometry.size.width)
                let items = arrangeItems(contents: contents, in: width, totalWidth: geometry.size.width)

                ZStack(alignment: .topLeading) {
                    ForEach(items) { item in
                        VStack(alignment: .leading, spacing: 5) { // Use a consistent spacing and adjust dynamically within views
                            Image(uiImage: item.content.image!)
                                .resizable()
                                .scaledToFit()
                                .frame(width: width, height: item.content.height(forWidth: width))
                                .clipped()
                            
                            if isCaptionShown {
                                Text(item.content.caption)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                    .frame(width: width, alignment: .leading)
                                    .opacity(isCaptionShown ? 1 : 0) // Use opacity to animate visibility
                            }
                        }
                        .position(x: CGFloat(item.column) * (width + horizontalSpacing) + width / 2,
                                  y: item.yOffset + item.content.height(forWidth: width) / 2)
                        .animation(.easeInOut(duration: 0.3)) // Apply animation to position change
                    }
                }
                .frame(width: geometry.size.width, height: calculateTotalHeight(items: items, in: width) + topPadding)
            }
        }
    }

    private func arrangeItems(contents: [RectangleContent], in columnWidth: CGFloat, totalWidth: CGFloat) -> [DynamicImageGridItem] {
        var items = [DynamicImageGridItem]()
        var yOffset: [CGFloat] = Array(repeating: topPadding, count: columns)
        
        for content in contents {
            let shortestColumnIndex = yOffset.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            let imageHeight = content.height(forWidth: columnWidth) // Dynamic height calculation based on aspect ratio
            let captionHeight: CGFloat = isCaptionShown ? 20 : 0 // Assuming a fixed caption height, adjust as necessary
            let totalHeight = imageHeight + (isCaptionShown ? (verticalSpacing / 2) : 0) + captionHeight // Adjusted padding for caption
            items.append(DynamicImageGridItem(content: content, column: shortestColumnIndex, yOffset: yOffset[shortestColumnIndex]))
            yOffset[shortestColumnIndex] += totalHeight + verticalSpacing
        }
        
        return items
    }




    private func calculateTotalHeight(items: [DynamicImageGridItem], in columnWidth: CGFloat) -> CGFloat {
        let maxHeight = items.reduce(into: [CGFloat](repeating: 0, count: columns)) { partialResult, item in
            partialResult[item.column] = max(partialResult[item.column], item.yOffset + item.content.height(forWidth: columnWidth))
        }.max() ?? 0

        return maxHeight
    }
}

extension RectangleContent {
    func height(forWidth width: CGFloat) -> CGFloat {
        // Provide a default aspect ratio (e.g., 1) in case the image or its dimensions are nil
        let aspectRatio = (self.image?.size.width ?? 1) / (self.image?.size.height ?? 1)
        return width / aspectRatio
    }
}
