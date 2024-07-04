import Foundation

extension Data {
    init(
        jsonFileName: String
    ) {
        do {
            guard let path = Bundle.main.path(forResource: jsonFileName, ofType: "json") else {
                throw "File not found: \(jsonFileName)"
            }
            self = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        } catch {
            self = .init()
        }
    }
}

extension String: LocalizedError {
    public var errorDescription: String? { self }
}
