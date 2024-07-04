import UIKit

extension UIApplication {

    static var isInSwiftUIPreviewMode: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
}
