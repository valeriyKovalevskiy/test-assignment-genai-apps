import UIKit

struct ApplicationSettings {
    
    static var shared = ApplicationSettings()
    private init() {}
    
    var systemVersion: String {
        UIDevice.current.systemVersion
    }
    
    var vendorIdentifier: String {
        UIDevice.current.identifierForVendor?.uuidString ?? ""
    }
    
    var versionNumber: String {
        Bundle.main.versionNumber
    }
    
    var buildNumber: String {
        Bundle.main.buildNumber
    }
    
    var readableVersionAndBuild: String {
        Bundle.main.versionAndBuildNumber
    }
    
    var timeZone: String {
        TimeZone.current.identifier
    }
    
    var isInSwiftUIPreviewMode: Bool {
        guard isDebug else {
            return false
        }
        
        return UIApplication.isInSwiftUIPreviewMode
    }
}

extension ApplicationSettings {
    
    enum Environment {
        case debug
        case beta
        case rc
        case production
    }
    
    var developmentFeaturesAvailable: Bool {
        environment == .beta || environment == .debug
    }
    
    var environment: Environment {
        if isDebug { return .debug }
        
        guard isStaging else {
            return isTestFlight ? .rc : .production
        }
        return .beta
    }
    
    private var isTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }
    
    var isDebug: Bool {
#if DEBUG
        return true
#else
        return false
#endif
    }
    
    var isStaging: Bool {
#if STAGING
        return true
#else
        return false
#endif
    }
    
    var isSimulator: Bool {
#if targetEnvironment(simulator)
        return true
#else
        return false
#endif
    }
}
