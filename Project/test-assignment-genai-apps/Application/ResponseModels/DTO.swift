import Foundation

/// Data Trandfer Object Namespace
enum DTO {}

// MARK: - ToDomainMappingType

protocol ToDomainMappingType {
    associatedtype DomainType
    func toDomain() throws -> DomainType
}
