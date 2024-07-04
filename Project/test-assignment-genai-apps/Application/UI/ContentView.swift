import SwiftUI
import Combine

final class ContentViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    func fetch() {
        API.MostPopular.Viewed(period: 1)
            .fakeRequest()
            .compactMap { try? $0.toDomain() }
            .receive(on: DispatchQueue.main)
            .sinkResult { result in
                switch result {
                case .success(let feed):
                    print(feed)
                    
                case .failure(let error):
                    print(error)
                }
            }
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
            Text("Hello, world!")
        }
        .padding()
        .onAppear { viewModel.fetch() }
    }
    

}

#Preview {
    ContentView(viewModel: .init())
}
