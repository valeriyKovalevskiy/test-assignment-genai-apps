import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        NavigationView {
            contentView
                .toolbar { toolbar }
                .onAppear { viewModel.fetchMostPopularArticles() }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu(
                content: {
                    makeMenuButton(period: .one)
                    makeMenuButton(period: .seven)
                    makeMenuButton(period: .thirty)
                },
                label: { makePeriodLabelText(period: viewModel.daysPeriod) }
            )
        }
    }
    
    private func makeMenuButton(period: MostPopularArticle.DaysPeriod) -> some View {
        Button(
            action: { viewModel.changeDaysPeriod(to: period) },
            label: { makePeriodLabelText(period: period) }
        )
    }
    
    private func makePeriodLabelText(period: MostPopularArticle.DaysPeriod) -> some View {
        Text("Time period: \(period.rawValue) days")
    }

    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading.contains(.mostPopulars) {
            ProgressView()
        } else {
            articlesListView
        }
    }
    
    private var articlesListView: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        ContentView(viewModel: .init())
    }
}
