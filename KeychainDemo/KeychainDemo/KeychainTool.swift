//
//  KeychainTool.swift
//  KeychainDemo
//
//  Created by jiao on 2025/12/8.
//

import Foundation
import Security

@preconcurrency
class KeychainTool: @unchecked Sendable {
    
    // MARK: - Error Types
    enum KeychainError: Error {
        case encodingFailed
        case decodingFailed
        case saveFailed(OSStatus)
        case readFailed(OSStatus)
        case deleteFailed(OSStatus)
        case itemNotFound
        
        var localizedDescription: String {
            switch self {
            case .encodingFailed:
                return "数据编码失败"
            case .decodingFailed:
                return "数据解码失败"
            case .saveFailed(let status):
                return "保存失败，错误代码: \(status)"
            case .readFailed(let status):
                return "读取失败，错误代码: \(status)"
            case .deleteFailed(let status):
                return "删除失败，错误代码: \(status)"
            case .itemNotFound:
                return "未找到数据"
            }
        }
    }
    
    // MARK: - Singleton
    static let shared = KeychainTool()
    
    // MARK: - Properties
    private let service: String
    private let account: String
    
    // MARK: - Initialization
    private init(service: String = "com.keychaindemo.stringarray", account: String = "stringArrayData") {
        self.service = service
        self.account = account
    }
    
    // MARK: - Testing Support
    #if DEBUG
    /// 创建测试实例（仅用于测试）
    static func createTestInstance(service: String) -> KeychainTool {
        return KeychainTool(service: service)
    }
    #endif
    
    // MARK: - Private Helper Methods
    
    /// 构建查询字典
    private func buildQuery() -> [String: Any] {
        return [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
    
    /// 从钥匙串读取完整的字典数据
    private func readDictionary() throws -> [String: [String]] {
        guard let data = try readData() else {
            return [:]
        }
        
        guard let dictionary = try? JSONDecoder().decode([String: [String]].self, from: data) else {
            throw KeychainError.decodingFailed
        }
        
        return dictionary
    }
    
    /// 保存完整的字典数据到钥匙串
    private func saveDictionary(_ dictionary: [String: [String]]) throws {
        guard let data = try? JSONEncoder().encode(dictionary) else {
            throw KeychainError.encodingFailed
        }
        try saveData(data)
    }
    
    /// 从钥匙串读取数据
    private func readData() throws -> Data? {
        var query = buildQuery()
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess {
            return result as? Data
        } else if status == errSecItemNotFound {
            return nil
        } else {
            throw KeychainError.readFailed(status)
        }
    }
    
    /// 保存数据到钥匙串
    private func saveData(_ data: Data) throws {
        let query = buildQuery()
        
        // 先尝试删除已存在的项
        SecItemDelete(query as CFDictionary)
        
        // 添加新项
        var attributes = query
        attributes[kSecValueData as String] = data
        
        let status = SecItemAdd(attributes as CFDictionary, nil)
        
        if status != errSecSuccess {
            throw KeychainError.saveFailed(status)
        }
    }
    
    /// 从钥匙串删除数据
    private func deleteData() throws {
        let query = buildQuery()
        let status = SecItemDelete(query as CFDictionary)
        
        if status != errSecSuccess && status != errSecItemNotFound {
            throw KeychainError.deleteFailed(status)
        }
    }
    
    // MARK: - Public Methods
    
    /// 为指定 username 保存字符串数组到钥匙串
    /// - Parameters:
    ///   - strings: 要保存的字符串数组
    ///   - username: 用户名，作为字典的键
    /// - Throws: KeychainError
    func saveStringArray(_ strings: [String], for username: String) throws {
        var dictionary = try readDictionary()
        dictionary[username] = strings
        try saveDictionary(dictionary)
    }
    
    /// 读取指定 username 对应的字符串数组
    /// - Parameter username: 用户名
    /// - Returns: 读取到的字符串数组，如果不存在则返回空数组
    /// - Throws: KeychainError
    func readStringArray(for username: String) throws -> [String] {
        let dictionary = try readDictionary()
        return dictionary[username] ?? []
    }
    
    /// 为指定 username 的数组添加单个字符串
    /// - Parameters:
    ///   - string: 要添加的字符串
    ///   - username: 用户名
    /// - Throws: KeychainError
    func addString(_ string: String, for username: String) throws {
        var dictionary = try readDictionary()
        var currentArray = dictionary[username] ?? []
        
        // 避免重复添加
        if !currentArray.contains(string) {
            currentArray.append(string)
            dictionary[username] = currentArray
            try saveDictionary(dictionary)
        }
    }
    
    /// 从指定 username 的数组中删除指定字符串
    /// - Parameters:
    ///   - string: 要删除的字符串
    ///   - username: 用户名
    /// - Throws: KeychainError
    func removeString(_ string: String, for username: String) throws {
        var dictionary = try readDictionary()
        guard var currentArray = dictionary[username] else {
            // username 不存在，直接返回
            return
        }
        
        if let index = currentArray.firstIndex(of: string) {
            currentArray.remove(at: index)
            
            if currentArray.isEmpty {
                // 如果数组为空，从字典中删除该 username
                dictionary.removeValue(forKey: username)
            } else {
                dictionary[username] = currentArray
            }
            
            if dictionary.isEmpty {
                // 如果整个字典为空，删除钥匙串项
                try deleteData()
            } else {
                try saveDictionary(dictionary)
            }
        }
    }
    
    /// 判断指定 username 的数组中是否包含任意给定字符串
    /// - Parameters:
    ///   - strings: 要检查的字符串数组
    ///   - username: 用户名
    /// - Returns: 如果有任何一个字符串存在则返回 true，否则返回 false
    /// - Throws: KeychainError
    func containsAny(_ strings: [String], for username: String) throws -> Bool {
        let currentArray = try readStringArray(for: username)
        
        for string in strings {
            if currentArray.contains(string) {
                return true
            }
        }
        
        return false
    }
    
    /// 删除指定 username 的所有数据
    /// - Parameter username: 用户名
    /// - Throws: KeychainError
    func clearUser(_ username: String) throws {
        var dictionary = try readDictionary()
        dictionary.removeValue(forKey: username)
        
        if dictionary.isEmpty {
            try deleteData()
        } else {
            try saveDictionary(dictionary)
        }
    }
    
    /// 获取所有的 username 列表
    /// - Returns: 所有用户名的数组
    /// - Throws: KeychainError
    func getAllUsernames() throws -> [String] {
        let dictionary = try readDictionary()
        return Array(dictionary.keys)
    }
    
    /// 清除所有存储的数据
    /// - Throws: KeychainError
    func clearAll() throws {
        try deleteData()
    }
}
