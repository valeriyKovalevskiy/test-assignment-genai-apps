import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        contentView
            .onAppear { viewModel.fetchMostPopularArticles() }
    }
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading.contains(.mostPopulars) {
            ProgressView()
        } else {
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                Text("Hello, world!")
            }
            .padding()
        }
    }
}

#Preview {
    ContentView(viewModel: .init())
}
