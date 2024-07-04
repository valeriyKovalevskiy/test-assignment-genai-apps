import SwiftUI

@main
struct test_assignment_genai_appsApp: App {
    
    var body: some Scene {
        WindowGroup {
            MostPopularArticlesView(viewModel: .init())
        }
    }
}
