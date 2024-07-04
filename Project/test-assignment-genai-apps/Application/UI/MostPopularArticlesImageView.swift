import Kingfisher
import SwiftUI

struct MostPopularArticlesImageView: View {
    let image: MostPopularArticle.Image?
    
    var body: some View {
        Group {
            if let image = image {
                KFImage
                    .url(image.url)
                    .downloadPriority(0.5)
                    .resizing(
                        referenceSize: .init(width: image.width, height: image.height),
                        mode: .aspectFill
                    )
                    .loadDiskFileSynchronously()
                    .cacheMemoryOnly()
                    .fade(duration: 0.25)
            } else {
                Circle()
                    .fill(Color.gray)
            }
        }
        .frame(width: 50, height: 50)
        .background(Color.gray)
        .clipShape(Circle())
    }
}
