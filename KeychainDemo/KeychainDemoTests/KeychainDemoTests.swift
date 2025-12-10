//
//  KeychainDemoTests.swift
//  KeychainDemoTests
//
//  Created by jiao on 2025/12/8.
//

import Testing
@testable import KeychainDemo
import Foundation

struct KeychainToolTests {
    
    // 使用唯一的 service 名称避免测试之间的干扰
    let testService = "com.keychaindemo.test.\(UUID().uuidString)"
    let testUsername = "testUser"
    
    // 创建测试实例的辅助方法
    func createTestInstance() -> KeychainTool {
        return KeychainTool.createTestInstance(service: testService)
    }
    
    // MARK: - 测试保存和读取字符串数组
    
    @Test func testSaveAndReadStringArray() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 测试保存数组
        let testArray = ["apple", "banana", "orange"]
        try keychainTool.saveStringArray(testArray, for: testUsername)
        
        // 测试读取数组
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == testArray)
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testReadEmptyArray() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 读取不存在的数组应该返回空数组
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray.isEmpty)
    }
    
    @Test func testSaveEmptyArray() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存空数组
        try keychainTool.saveStringArray([], for: testUsername)
        
        // 读取应该得到空数组
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray.isEmpty)
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testOverwriteArray() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存第一个数组
        try keychainTool.saveStringArray(["one", "two"], for: testUsername)
        
        // 覆盖保存第二个数组
        try keychainTool.saveStringArray(["three", "four", "five"], for: testUsername)
        
        // 读取应该得到第二个数组
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == ["three", "four", "five"])
        
        // 清理
        try keychainTool.clearAll()
    }
    
    // MARK: - 测试添加字符串
    
    @Test func testAddStringToEmptyArray() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 向空数组添加字符串
        try keychainTool.addString("first", for: testUsername)
        
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == ["first"])
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testAddStringToExistingArray() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 先保存一个数组
        try keychainTool.saveStringArray(["apple", "banana"], for: testUsername)
        
        // 添加新字符串
        try keychainTool.addString("orange", for: testUsername)
        
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == ["apple", "banana", "orange"])
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testAddDuplicateString() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存数组
        try keychainTool.saveStringArray(["apple", "banana"], for: testUsername)
        
        // 尝试添加已存在的字符串
        try keychainTool.addString("apple", for: testUsername)
        
        // 数组应该保持不变
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == ["apple", "banana"])
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testAddMultipleStrings() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 连续添加多个字符串
        try keychainTool.addString("one", for: testUsername)
        try keychainTool.addString("two", for: testUsername)
        try keychainTool.addString("three", for: testUsername)
        
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == ["one", "two", "three"])
        
        // 清理
        try keychainTool.clearAll()
    }
    
    // MARK: - 测试删除字符串
    
    @Test func testRemoveExistingString() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存数组
        try keychainTool.saveStringArray(["apple", "banana", "orange"], for: testUsername)
        
        // 删除存在的字符串
        try keychainTool.removeString("banana", for: testUsername)
        
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == ["apple", "orange"])
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testRemoveNonExistingString() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存数组
        try keychainTool.saveStringArray(["apple", "banana"], for: testUsername)
        
        // 删除不存在的字符串
        try keychainTool.removeString("orange", for: testUsername)
        
        // 数组应该保持不变
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == ["apple", "banana"])
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testRemoveLastString() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存只有一个元素的数组
        try keychainTool.saveStringArray(["onlyOne"], for: testUsername)
        
        // 删除最后一个字符串
        try keychainTool.removeString("onlyOne", for: testUsername)
        
        // 应该返回空数组，因为该 username 被删除
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray.isEmpty)
    }
    
    @Test func testRemoveFromEmptyArray() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 从空数组删除应该不抛出异常
        try keychainTool.removeString("anything", for: testUsername)
        
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray.isEmpty)
    }
    
    // MARK: - 测试 containsAny 方法
    
    @Test func testContainsAny_WithMatch() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存数组
        try keychainTool.saveStringArray(["apple", "banana", "orange"], for: testUsername)
        
        // 测试包含的情况
        let contains = try keychainTool.containsAny(["grape", "banana", "kiwi"], for: testUsername)
        #expect(contains == true)
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testContainsAny_WithoutMatch() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存数组
        try keychainTool.saveStringArray(["apple", "banana", "orange"], for: testUsername)
        
        // 测试不包含的情况
        let contains = try keychainTool.containsAny(["grape", "kiwi", "mango"], for: testUsername)
        #expect(contains == false)
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testContainsAny_EmptyStoredArray() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 存储的数组为空
        let contains = try keychainTool.containsAny(["apple", "banana"], for: testUsername)
        #expect(contains == false)
    }
    
    @Test func testContainsAny_EmptyCheckArray() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存数组
        try keychainTool.saveStringArray(["apple", "banana"], for: testUsername)
        
        // 检查空数组
        let contains = try keychainTool.containsAny([], for: testUsername)
        #expect(contains == false)
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testContainsAny_AllMatch() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存数组
        try keychainTool.saveStringArray(["apple", "banana", "orange"], for: testUsername)
        
        // 所有元素都匹配
        let contains = try keychainTool.containsAny(["apple", "banana"], for: testUsername)
        #expect(contains == true)
        
        // 清理
        try keychainTool.clearAll()
    }
    
    // MARK: - 测试清除功能
    
    @Test func testClearAll() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 保存数据
        try keychainTool.saveStringArray(["apple", "banana", "orange"], for: testUsername)
        
        // 验证数据存在
        var readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(!readArray.isEmpty)
        
        // 清除所有数据
        try keychainTool.clearAll()
        
        // 验证数据已清除
        readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray.isEmpty)
    }
    
    @Test func testClearAll_OnEmptyKeychain() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 在空钥匙串上清除应该不抛出异常
        try keychainTool.clearAll()
        
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray.isEmpty)
    }
    
    // MARK: - 测试特殊字符和边界情况
    
    @Test func testSpecialCharacters() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 测试包含特殊字符的字符串
        let specialStrings = ["hello@world.com", "password#123", "中文测试", "emoji😀🎉"]
        try keychainTool.saveStringArray(specialStrings, for: testUsername)
        
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == specialStrings)
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testLargeArray() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 测试大数组
        let largeArray = (0..<1000).map { "item_\($0)" }
        try keychainTool.saveStringArray(largeArray, for: testUsername)
        
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == largeArray)
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testEmptyStrings() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 测试包含空字符串的数组
        let arrayWithEmpty = ["", "apple", "", "banana"]
        try keychainTool.saveStringArray(arrayWithEmpty, for: testUsername)
        
        let readArray = try keychainTool.readStringArray(for: testUsername)
        #expect(readArray == arrayWithEmpty)
        
        // 清理
        try keychainTool.clearAll()
    }
    
    // MARK: - 测试多用户隔离性
    
    @Test func testMultipleUsersIsolation() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 为不同用户保存不同数据
        try keychainTool.saveStringArray(["user1_data1", "user1_data2"], for: "user1")
        try keychainTool.saveStringArray(["user2_data1", "user2_data2"], for: "user2")
        
        // 验证数据隔离
        let array1 = try keychainTool.readStringArray(for: "user1")
        let array2 = try keychainTool.readStringArray(for: "user2")
        
        #expect(array1 == ["user1_data1", "user1_data2"])
        #expect(array2 == ["user2_data1", "user2_data2"])
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testGetAllUsernames() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 为多个用户添加数据
        try keychainTool.saveStringArray(["data1"], for: "alice")
        try keychainTool.saveStringArray(["data2"], for: "bob")
        try keychainTool.saveStringArray(["data3"], for: "charlie")
        
        // 获取所有用户名
        let usernames = try keychainTool.getAllUsernames()
        
        #expect(usernames.count == 3)
        #expect(usernames.contains("alice"))
        #expect(usernames.contains("bob"))
        #expect(usernames.contains("charlie"))
        
        // 清理
        try keychainTool.clearAll()
    }
    
    @Test func testClearUser() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 为多个用户添加数据
        try keychainTool.saveStringArray(["data1"], for: "user1")
        try keychainTool.saveStringArray(["data2"], for: "user2")
        
        // 删除 user1
        try keychainTool.clearUser("user1")
        
        // 验证 user1 已被删除
        let array1 = try keychainTool.readStringArray(for: "user1")
        #expect(array1.isEmpty)
        
        // 验证 user2 仍然存在
        let array2 = try keychainTool.readStringArray(for: "user2")
        #expect(array2 == ["data2"])
        
        // 清理
        try keychainTool.clearAll()
    }
    
    // MARK: - 集成测试
    
    @Test func testCompleteWorkflow() async throws {
        let keychainTool = createTestInstance()
        
        // 清理测试环境
        try? keychainTool.clearAll()
        
        // 1. 为 user1 添加一些字符串
        try keychainTool.addString("apple", for: "user1")
        try keychainTool.addString("banana", for: "user1")
        try keychainTool.addString("orange", for: "user1")
        
        // 2. 验证 user1 包含性
        var contains = try keychainTool.containsAny(["banana", "grape"], for: "user1")
        #expect(contains == true)
        
        // 3. 为 user2 添加数据
        try keychainTool.addString("cat", for: "user2")
        try keychainTool.addString("dog", for: "user2")
        
        // 4. 从 user1 删除一个字符串
        try keychainTool.removeString("banana", for: "user1")
        
        // 5. 再次验证 user1
        contains = try keychainTool.containsAny(["banana"], for: "user1")
        #expect(contains == false)
        
        // 6. 验证 user2 没有受影响
        let user2Array = try keychainTool.readStringArray(for: "user2")
        #expect(user2Array == ["cat", "dog"])
        
        // 7. 读取 user1 最终数组
        let finalArray = try keychainTool.readStringArray(for: "user1")
        #expect(finalArray == ["apple", "orange"])
        
        // 8. 验证用户名列表
        let usernames = try keychainTool.getAllUsernames()
        #expect(usernames.count == 2)
        #expect(usernames.contains("user1"))
        #expect(usernames.contains("user2"))
        
        // 9. 清理
        try keychainTool.clearAll()
        
        // 10. 验证清理后为空
        let emptyArray = try keychainTool.readStringArray(for: "user1")
        #expect(emptyArray.isEmpty)
        
        let emptyUsernames = try keychainTool.getAllUsernames()
        #expect(emptyUsernames.isEmpty)
    }
}

