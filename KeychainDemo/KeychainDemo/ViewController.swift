//
//  ViewController.swift
//  KeychainDemo
//
//  Created by jiao on 2025/12/8.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // KeychainTool 使用示例
        demoKeychainTool()
    }
    
    private func demoKeychainTool() {
        let keychain = KeychainTool.shared
        
        do {
            // 为用户 "alice" 保存字符串数组
            try keychain.saveStringArray(["photos", "documents", "videos"], for: "alice")
            
            // 为用户 "bob" 添加权限
            try keychain.addString("admin", for: "bob")
            try keychain.addString("editor", for: "bob")
            
            // 读取 alice 的数据
            let aliceData = try keychain.readStringArray(for: "alice")
            print("Alice's data: \(aliceData)")
            
            // 检查 bob 是否有特定权限
            let hasAdminPermission = try keychain.containsAny(["admin", "superuser"], for: "bob")
            print("Bob has admin permission: \(hasAdminPermission)")
            
            // 获取所有用户
            let allUsers = try keychain.getAllUsernames()
            print("All users: \(allUsers)")
            
            // 从 alice 的数据中删除一个项目
            try keychain.removeString("documents", for: "alice")
            
            // 删除整个用户
            try keychain.clearUser("bob")
            
            print("KeychainTool demo completed successfully!")
            
        } catch {
            print("Error: \(error)")
        }
    }
}

