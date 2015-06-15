// 网络交互的数据格式

import UIKit

// 一款APP应用，几乎离不开网络交互，而JSON作为网络交互最主流的数据格式，拥有着格式简单，清晰易懂，节省流量等特点，几乎所有语言平台都支持的一种网络数据格式规范。对于iOS来说也不例外

// 在 Objective C (OC) 时代，有着大量的第三方JSON解析库，后来苹果公司也在自身的SDK中集成了JSON解析功能 NSJSONSerialization 。而且经过严格测试，其解析效率远超众多第三方库。

// 原本的 NSJSONSerialization 在 OC 下还是很方便的, 但是 Swift 登场后, 可选值的引入, 与类型需要显示的强行转换，就使得JSON 的解析代码 显得臃肿而啰嗦。

var json = "{\"succ\":true, \"code\":0, \"msg\":\"用户注册成功\", \"data\":[{\"key\":2},{\"key\":3},{\"key\":5}]}"

/* (给大家讲解一下模拟JSON内容:
 * succ 表示网络访问的成功与失败, 
 * code 表示错误代码, 
 * msg 表示错误或成功的提示消息, 
 * data 表示其他服务器返回数据)
 */

// 下面就给大家示范一下 Swift 下应该如何解析我们模拟网络访问的这个 JSON

let jsonData = json.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)

var error:NSError? = nil
if let dict = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions(0), error: &error) as? NSDictionary {
    
    let succ:Bool = (dict["succ"] as? NSNumber)?.boolValue ?? false
    let code:Int = (dict["code"] as? NSNumber)?.integerValue ?? 0
    let msg:String = (dict["msg"] as? String) ?? ""
    
    if let datas:[NSDictionary] = (dict["data"] as? [NSDictionary]) {
        for data in datas {
            let key:Int = (data["key"] as? NSNumber)?.integerValue ?? 0
            println("list \(key)")
        }
        println("JSON解析成功")
    } else {
        println("未知的data格式")
    }
    
} else {
    let 解析失败原因 = error?.localizedDescription ?? "JSON结构不是对象(有可能是数组)"
    println("JSON解析失败:\(解析失败原因)")
}


// 看了这些，你可能会说，还好啊，但这是经过我优化后的写法，算是简洁易懂了，比起动辄if let N次的月牙形代码，已经是最容易阅读和理解的了。而一片片的？和 as 强转仍然使人眼晕.

// 有办法简化么? 答案是肯定的，对程序来说，只有我们不会的，没有不可能的。

// 简化的办法有 4 种:

// 第一种是采用其他语言成熟的解决方案，例如像JAVA 那样 定义 JSONObject 和 JSONArray 2个对象来封装，优点是方案成熟，且可以无限类似JAVA或其他语言的样式，这样那些从其他语言转 Swift 的程序员使用起来毫无压力，而且保持了统一的习惯和风格。 缺点是要写大量的代码，并自己写序列化方式来进行封装，与苹果原生的API也无兼容性可言，每次都要转来转去，很不方便。

// 第二种是一些奇才异能之士利用 闭包,自定义运算符,反射 等功能 将JSON数据映射到 结构体 或 对象上。优点：这在代码中是一种最理想的状态，可以充分利用代码自动完成功能，减少出错的可能，并且有助于团队协作。缺点：代码过于晦涩难懂，而且不能做到完全反射，每次转换还是要手写很多内容，而且很难阅读困难，给项目的可维护性带来了不利影响。

// 第三种是在第二种基础之上 让数据对象继承自 NSObject 利用 OC 的 KVC、KVO 功能进行自动映射，以达成更理想的状态。优点：对于原 OC 程序员无疑是一种福音，而且能够做到完全反射。缺点：仍然要自己实现 序列化方法。而且相对于其他语言转过来的开发者，对 KVC、KVO 的理解有一定要求，而且限制了数据对象的唯一可继承。（总结）虽然仍有缺点，但不失为一种十分可行的方案。『推荐』

// 第四种方法是利用 extension (类似 OC 的类目 功能) 给原生的 NSArray 和 NSDictionary 添加相应的获取方法。优点：不用定义全新的类，不会增加额外的内存负担，不必理会数据序列化问题，原生都是支持的。最契合iOS 的 SDK 在不止JSON,在用户配置文件,还有其他方面都有实际用途.『强烈推荐』

// 下面就演示第四种方式如何扩展，其他方式如果大家感兴趣我们会单独开辟一期来讲。


// 第一步 从网络获取的数据NSData 可以不必转成字符串, 直接解析JSON, 可以直接解析, 因此扩展 NSData

typealias JSONArray = (array:NSArray?, error:NSError?)
typealias JSONObject = (dict:NSDictionary?, error:NSError?)

extension NSData {
    
    func jsonParseToDictionary() -> JSONObject {
        var error:NSError? = nil
        let dict = NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions(0), error: &error) as? NSDictionary
        
        return (dict, error)
    }
    
    func jsonParseToArray() -> JSONArray {
        var error:NSError? = nil
        let array = NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions(0), error: &error) as? NSArray
        
        return (array, error)
    }
    
    // 为了方便，增加一个NSData 直接转 UTF8字符串的功能，这个很常用
    func toUTF8String() -> String? {
        return NSString(data: self, encoding: NSUTF8StringEncoding) as? String
    }
}

// 下一步扩展字符串,为了方便可以直接调用 NSData 的同名方法
extension String {
    
    func jsonParseToDictionary() -> JSONObject {
        return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!.jsonParseToDictionary()
    }
    
    func jsonParseToArray() -> JSONArray {
        return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!.jsonParseToArray()
    }
    
}

// 当然不仅仅如此，下面扩展 数组（NSArray） 和 字典（NSDictionary）


extension NSDictionary {
    
    func get<T> (key:NSCopying, defaultValue:T) -> T {
        
        if let object:AnyObject = self[key] {
            switch (object, defaultValue) {
                
            // 如果和默认值相同类型
            case (let result as T, _):
                return result
                
            // 如果是数字类型
            case (let result as NSNumber, let value as String):
                return result.stringValue as! T
            case (let result as NSNumber, let value as Bool):
                return result.boolValue as! T
            case (let result as NSNumber, let value as Int):
                return result.integerValue as! T
            case (let result as NSNumber, let value as UInt):
                return result.unsignedLongValue as! T
            case (let result as NSNumber, let value as Int8):
                return result.charValue as! T
            case (let result as NSNumber, let value as UInt8):
                return result.unsignedCharValue as! T
            case (let result as NSNumber, let value as Int16):
                return result.shortValue as! T
            case (let result as NSNumber, let value as UInt16):
                return result.unsignedShortValue as! T
            case (let result as NSNumber, let value as Int32):
                return result.intValue as! T
            case (let result as NSNumber, let value as UInt32):
                return result.unsignedIntValue as! T
            case (let result as NSNumber, let value as Int64):
                return result.longLongValue as! T
            case (let result as NSNumber, let value as UInt16):
                return result.unsignedLongLongValue as! T
            case (let result as NSNumber, let value as Float):
                return result.floatValue as! T
            case (let result as NSNumber, let value as Double):
                return result.doubleValue as! T
            case (let result as NSNumber, let value as NSDate):
                return NSDate(timeIntervalSince1970: result.doubleValue) as! T
                
                // 如果是字符串类型
            case (let result as NSString, let value as String):
                return result as! T
            case (let result as NSString, let value as Int):
                return result.integerValue as! T
            case (let result as NSString, let value as UInt):
                return UInt(result.integerValue) as! T
            case (let result as NSString, let value as Int8):
                return Int8(result.integerValue) as! T
            case (let result as NSString, let value as UInt8):
                return UInt8(result.integerValue) as! T
            case (let result as NSString, let value as Int16):
                return Int16(result.integerValue) as! T
            case (let result as NSString, let value as UInt16):
                return UInt16(result.integerValue) as! T
            case (let result as NSString, let value as Int32):
                return result.intValue as! T
            case (let result as NSString, let value as UInt32):
                return UInt32(result.intValue) as! T
            case (let result as NSString, let value as Int64):
                return result.longLongValue as! T
            case (let result as NSString, let value as UInt64):
                return UInt64(result.longLongValue) as! T
            case (let result as NSString, let value as Float):
                return result.floatValue as! T
            case (let result as NSString, let value as Double):
                return result.doubleValue as! T
            case (let result as String, let value as NSDate):
                var formater = NSDateFormatter()
                formater.dateFormat = "yyyy-MM-dd HH:mm:ss"
                if let date = formater.dateFromString(result) {
                    return date as! T
                } else {
                    formater.dateFormat = "yyyy-MM-dd"
                    if let date = formater.dateFromString(result) {
                        return date as! T
                    }
                }
                return defaultValue
                
            // 以下类型在 JSON 中 不太可能用到, 其他类型有可能用到
            //case (let result as String, let value as NSDate):
                
            default:
                return defaultValue
            }
        }
        return defaultValue
    }

}
