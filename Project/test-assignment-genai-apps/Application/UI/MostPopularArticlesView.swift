import SwiftUI

struct MostPopularArticlesView: View {
    @ObservedObject var viewModel: MostPopularArticlesViewModel
    
    var body: some View {
        NavigationView {
            contentView
                .navigationBarTitleDisplayMode(.inline)
                .navigationTitle("NY Times Most Popular")
                .toolbar { toolbar }
                .onAppear { viewModel.fetchMostPopularArticles() }
                .handleAlert(item: $viewModel.alertInfo)
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
    
    @ViewBuilder
    private var contentView: some View {
        if viewModel.isLoading.contains(.mostPopulars) {
            loadingStateView
        } else {
            articlesListView
        }
    }
    
    private var loadingStateView: some View {
        ProgressView()
    }
    
    private var emptyStateView: some View {
        Text("Empty")
            .foregroundColor(.primary)
            .font(.headline)
    }
    
    @ViewBuilder
    private var articlesListView: some View {
        if let articles = viewModel.articles, !articles.isEmpty {
            makeArticlesList(articles: articles)
        } else {
            emptyStateView
        }
    }
    
    private func makeMenuButton(period: MostPopularArticle.DaysPeriod) -> some View {
        Button(
            action: { viewModel.changeDaysPeriod(to: period) },
            label: { makePeriodLabelText(period: period) }
        )
    }
    
    @ViewBuilder
    private func makePeriodLabelText(period: MostPopularArticle.DaysPeriod?) -> some View {
        if let period = period {
            Text("\(period.rawValue) days")
                .foregroundColor(.primary)
                .font(.headline)
        }
    }
    
    private func makeArticlesList(articles: [MostPopularArticle]) -> some View {
        List {
            ForEach(articles, id: \.id) { article in
                if let url = article.url {
                    Link(
                        destination: url,
                        label: { makeArticleView(article: article) }
                    )
                    .shadow(color: .secondary, radius: 10)
                }
            }
        }
        .listStyle(.plain)
        
    }
    
    private func makeArticleView(article: MostPopularArticle) -> some View {
        HStack {
            MostPopularArticlesImageView(image: article.thumbnail)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(article.title)
                    .lineLimit(2)
                    .foregroundColor(.primary)
                    .font(.headline)
                
                HStack(alignment: .bottom) {
                    
                    if let author = article.author {
                        Text(author)
                            .font(.caption2)
                            .layoutPriority(0)
                            .minimumScaleFactor(0.8)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                    
                    if let date = article.publishedAt {
                        HStack {
                            Image(systemName: "calendar")
                            
                            Text(date)
                                .layoutPriority(1)
                                .minimumScaleFactor(0.6)
                                .lineLimit(1)
                        }
                    }
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .multilineTextAlignment(.leading)
            
            Image(systemName: "chevron.right")
                .font(.system(size: 24))
                .foregroundColor(.secondary)
        }
        .shadow(color: .clear, radius: 10)
    }
}

#Preview {
    NavigationView {
        MostPopularArticlesView(viewModel: .init())
    }
}
