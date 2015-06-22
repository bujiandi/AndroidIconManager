import Foundation

public typealias JSONArray = (array:NSArray?, error:ErrorType?)
public typealias JSONObject = (dict:NSDictionary?, error:ErrorType?)

extension NSData {
    
    public func jsonParseToDictionary() -> JSONObject {
        do {
            let dict = try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
            return (dict, nil)
        } catch let error {
            return (nil, error)
        }
    }
    
    public func jsonParseToArray() -> JSONArray {
        do {
            let array = try NSJSONSerialization.JSONObjectWithData(self, options: NSJSONReadingOptions(rawValue: 0)) as? NSArray
            return (array, nil)
        } catch let error {
            return (nil, error)
        }
    }
    
    // 为了方便，增加一个NSData 直接转 UTF8字符串的功能，这个很常用
    public func toUTF8String() -> String? {
        return NSString(data: self, encoding: NSUTF8StringEncoding) as? String
    }
}

extension String {
    
    public func jsonParseToDictionary() -> JSONObject {
        return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!.jsonParseToDictionary()
    }
    
    public func jsonParseToArray() -> JSONArray {
        return dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!.jsonParseToArray()
    }
    
}

infix operator ??= {
    associativity right
    precedence 90
    assignment
}

public func ??=<T>(inout lhs:T, rhs:AnyObject?) {
    lhs = rhs ?? lhs
}

public func ??<T>(optional: AnyObject?, @autoclosure defaultValue:() -> T) -> T {
    
    guard let object: AnyObject = optional else {
        return defaultValue()
    }
    // 如果和默认值相同类型
    if let result = object as? T { return result }
    
    let defaultValue:T = defaultValue()
    switch (object, defaultValue) {
        // 如果是数字类型
    case (let result as NSDictionary,  _ as NSArray):
        return result.allValues as! T
    case (let result as NSArray,  _ as NSDictionary):
        let dict:NSMutableDictionary = NSMutableDictionary()
        for var i:Int = 0; i<result.count; i++ {
            dict[i] = result[i]
        }
        return dict as! T
    case (let result as NSNumber, _ as NSArray):
        return NSArray(object: result) as! T
    case (let result as NSNumber, _ as String):
        return result.stringValue as! T
    case (let result as NSNumber, _ as Bool):
        return result.boolValue as! T
    case (let result as NSNumber, _ as Int):
        return result.integerValue as! T
    case (let result as NSNumber, _ as UInt):
        return result.unsignedLongValue as! T
    case (let result as NSNumber, _ as Int8):
        return result.charValue as! T
    case (let result as NSNumber, _ as UInt8):
        return result.unsignedCharValue as! T
    case (let result as NSNumber, _ as Int16):
        return result.shortValue as! T
    case (let result as NSNumber, _ as UInt16):
        return result.unsignedShortValue as! T
    case (let result as NSNumber, _ as Int32):
        return result.intValue as! T
    case (let result as NSNumber, _ as UInt32):
        return result.unsignedIntValue as! T
    case (let result as NSNumber, _ as Int64):
        return result.longLongValue as! T
    case (let result as NSNumber, _ as UInt16):
        return result.unsignedLongLongValue as! T
    case (let result as NSNumber, _ as Float):
        return result.floatValue as! T
    case (let result as NSNumber, _ as Double):
        return result.doubleValue as! T
    case (let result as NSNumber, _ as NSDate):
        return NSDate(timeIntervalSince1970: result.doubleValue) as! T
        
        // 如果是字符串类型
    case (let result as NSString, _ as NSArray):
        return NSArray(object: result) as! T
    case (let result as NSString, _ as String):
        return result as! T
    case (let result as NSString, _ as Bool):
        return result.boolValue as! T
    case (let result as NSString, _ as Int):
        return result.integerValue as! T
    case (let result as NSString, _ as UInt):
        return UInt(result.integerValue) as! T
    case (let result as NSString, _ as Int8):
        return Int8(result.integerValue) as! T
    case (let result as NSString, _ as UInt8):
        return UInt8(result.integerValue) as! T
    case (let result as NSString, _ as Int16):
        return Int16(result.integerValue) as! T
    case (let result as NSString, _ as UInt16):
        return UInt16(result.integerValue) as! T
    case (let result as NSString, _ as Int32):
        return result.intValue as! T
    case (let result as NSString, _ as UInt32):
        return UInt32(result.intValue) as! T
    case (let result as NSString, _ as Int64):
        return result.longLongValue as! T
    case (let result as NSString, _ as UInt64):
        return UInt64(result.longLongValue) as! T
    case (let result as NSString, _ as Float):
        return result.floatValue as! T
    case (let result as NSString, _ as Double):
        return result.doubleValue as! T
    case (let result as String, _ as Date):
        guard let date = Date(result) else {
            guard let date = Date(result, dateFormat:"yyyy-MM-dd") else {
                return defaultValue
            }
            return date as! T
        }
        return date as! T
    case (let result as String, _ as NSDate):
        let formater = NSDateFormatter()
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
    default:
        return defaultValue
    }
}


