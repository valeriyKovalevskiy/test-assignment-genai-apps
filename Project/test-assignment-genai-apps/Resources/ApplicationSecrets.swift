import Foundation

struct ApplicationSecrets {
    // hide into some kind of xcconfig and exclude from linked project file
    // for better protection of app secrets
    // for now i'll leave it simple stupid
    static var mostPopularKey: String { "mmWxqDBfCTKD2Ryag1eCwhEhPFOP23t9" }
}
