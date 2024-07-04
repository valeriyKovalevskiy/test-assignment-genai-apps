import SwiftUI

extension View {
    /// Handles Alerts with default implementation
    func handleAlert(
        item: Binding<AlertInfo?>,
        alertBuilder: ((AlertInfo) -> Alert?)? = nil
    ) -> some View {
        self.alert(item: item) { item in
            switch item {
            case let .message(message):
                return Alert(
                    title: Text(message),
                    dismissButton: .default(Text("Got it"))
                )

            case let .error(error):
                if ApplicationSettings.shared.environment == .production {
                    return Alert(
                        title: Text("Error occured"),
                        message: Text(error.localizedDescription),
                        dismissButton: .default(Text("OK"))
                    )

                } else {
                    return Alert(
                        title: Text(error.localizedDescription),
                        primaryButton: .default(Text("Copy")) { UIPasteboard.general.string = error.localizedDescription },
                        secondaryButton: .default(Text("Ok"))
                    )
                }
            }
        }
    }
}
