// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation

let service: String = "NGFKeychain"

enum KeychainErrors: Error {
    /// Error with the keychain creting and checking
    case creatingError
    /// Error for operation
    case operationError
}

public class KeychainWrapper: NSObject {
    
    
    public static func set(value: Data, item: String) throws {
        // If the value exists `update the value`
        if try KeychainOperations.exists(item: item) {
            try KeychainOperations.update(value: value, item: item)
        } else {
            // Just insert
            try KeychainOperations.add(value: value, item: item)
        }
    }
    
    
    public static func get(item: String) throws -> Data? {
        if try KeychainOperations.exists(item: item) {
            return try KeychainOperations.retreive(item: item)
        } else {
            throw KeychainErrors.operationError
        }
    }
        
        public static func delete(item: String) throws {
            if try KeychainOperations.exists(item: item) {
                return try KeychainOperations.delete(item: item)
            } else {
                throw KeychainErrors.operationError
            }
        }
}

class KeychainOperations: NSObject {
    
    static func add(value: Data, item: String) throws {
        let status = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: item,
            kSecAttrService: service,
            // Allow background access:
            kSecAttrAccessible: kSecAttrAccessibleAfterFirstUnlock,
            kSecValueData: value,
            ] as NSDictionary, nil)
        guard status == errSecSuccess else { throw KeychainErrors.operationError }
    }
    
    static func update(value: Data, item: String) throws {
        let status = SecItemUpdate([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: item,
            kSecAttrService: service,
            ] as NSDictionary, [
                kSecValueData: value,
                ] as NSDictionary)
        guard status == errSecSuccess else { throw KeychainErrors.operationError }
    }
    
    static func retreive(item: String) throws -> Data? {
        /// Result of getting the item
        var result: AnyObject?
        /// Status for the query
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: item,
            kSecAttrService: service,
            kSecReturnData: true,
            ] as NSDictionary, &result)
        // Switch to conditioning statement
        switch status {
        case errSecSuccess:
            return result as? Data
        case errSecItemNotFound:
            return nil
        default:
            throw KeychainErrors.operationError
        }
    }
    
    static func delete(item: String) throws {
        /// Status for the query
        let status = SecItemDelete([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: item,
            kSecAttrService: service,
            ] as NSDictionary)
        guard status == errSecSuccess else { throw KeychainErrors.operationError }
    }
    
    static func exists(item: String) throws -> Bool {
        /// Constant with current status about the keychain to check
        let status = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: item,
            kSecAttrService: service,
            kSecReturnData: false,
            ] as NSDictionary, nil)
        // Switch to conditioning statement
        switch status {
        case errSecSuccess:
            return true
        case errSecItemNotFound:
            return false
        default:
            throw KeychainErrors.creatingError
        }
    }
}
