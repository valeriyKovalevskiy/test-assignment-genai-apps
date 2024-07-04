import Foundation

// response models aka data transfer object models and domain models will allow you fetch safely everything you want and then map only what you really need for ui presentation
// i prefer always make dto models as optional to prevent empty fields / broken responses errors and map it into empty field.

/// Data Trandfer Object Namespace
enum DTO {}

// MARK: - ToDomainMappingType

protocol ToDomainMappingType {
    associatedtype DomainType
    func toDomain() throws -> DomainType
}
