//
//  Array+Utils.swift
//
//  Created by bujiandi(慧趣小歪) on 14/10/4.
//

import Foundation

extension Array {
    
    // 用指定分隔符 连接 数组元素 为 字符串
    func componentsJoinedByString(separator: String) -> String {
        var result = ""
        for item:T in self {
            if !result.isEmpty {
                result += separator
            }
            result += "\(item)"
        }
        return result
    }
    
    // 利用闭包功能 给数组添加 包涵方法
    func contains(includeElement: (T) -> Bool) -> Bool {
        for item in self where includeElement(item) {
            return true
        }
        return false
    }
    
    // 利用闭包功能 给数组添加 查找首个符合条件元素 的 方法
    func find(includeElement: (T) -> Bool) -> T? {
        for item in self where includeElement(item) {
            return item
        }
        return nil
    }
    
    // 利用闭包功能 给数组添加 查找首个符合条件元素下标 的 方法
    func indexOf(includeElement: (T) -> Bool) -> Int {
        for var i:Int = 0; i<count; i++ {
            if includeElement(self[i]) {
                return i
            }
        }
        return NSNotFound
    }
    
    // 利用闭包功能 获取数组元素某个属性值的数组
    func valuesFor<U>(includeElement: (T) -> U) -> [U] {
        var result:[U] = []
        for item:T in self {
            result.append(includeElement(item))
        }
        return result
    }
    
    // 利用闭包功能 获取符合条件数组元素 相关内容的数组
    func valuesFor<U>(includeElement: (T) -> U?) -> [U] {
        var result:[U] = []
        for item:T in self {
            if let u:U = includeElement(item) {
                result.append(u)
            }
        }
        return result
    }
}