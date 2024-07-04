import Foundation

extension Bundle {

    private var CFBundleVersion: String { "CFBundleVersion" }
    private var CFBundleShortVersionString: String { "CFBundleShortVersionString" }
    private var CFBundleName: String { "CFBundleName" }
    private var genericUnknownString: String { "Unknown" }

    /// Returns the current app name
    var bundleName: String {
        infoDictionary?[CFBundleName] as? String ?? genericUnknownString
    }

    /// Returns the current app version as per app's Info.plist
    ///
    ///     let versionNumber = Bundle.main.versionNumber
    ///     print(versionNumber) // 4.28.2
    var versionNumber: String {
        infoDictionary?[CFBundleShortVersionString] as? String ?? genericUnknownString
    }

    /// Returns the current app build number as per app's Info.plist i.e 115
    ///
    ///     let buildNumber = Bundle.main.buildNumber
    ///     print(buildNumber) // 115
    var buildNumber: String {
        infoDictionary?[CFBundleVersion] as? String ?? genericUnknownString
    }

    /// Returns the a concat string with version + build number as per app's Info.plist
    ///
    ///     let version = Bundle.main.versionAndBuildNumber
    ///     print(version) // "4.28.2.115"
    var versionAndBuildNumber: String {
        "\(versionNumber).\(buildNumber)"
    }
}
