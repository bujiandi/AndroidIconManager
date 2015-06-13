
#if os(iOS)
import UIKit
#elseif os(OSX)
import Foundation
#endif

extension String {
    
    // MARK: - 取类型名
    static func typeNameFromClass(aClass:AnyClass) -> String {
        let name = NSStringFromClass(aClass)
        let demangleName = _stdlib_demangleName(name)
        return demangleName.componentsSeparatedByString(".").last!
    }
//
//    static func typeNameFromAny(thing:Any) -> String {
//        let name = _stdlib_getTypeName(thing)
//        let demangleName = _stdlib_demangleName(name)
//        return demangleName.componentsSeparatedByString(".").last!
//    }
    
    // MARK: - 取大小
    #if os(iOS)
//    func boundingRectWithSize(size: CGSize, defaultFont:UIFont = UIFont.systemFontOfSize(16), lineBreakMode:NSLineBreakMode = .ByWordWrapping) -> CGSize {
//        var label:UILabel = UILabel()
//        label.lineBreakMode = lineBreakMode
//        label.font = defaultFont
//        label.numberOfLines = 0
//        label.text = self
//        return label.sizeThatFits(size)
//    }
    #endif
    
    // MARK: - 取路径末尾文件名
    public var stringByDeletingPathPrefix:String {
        return self.componentsSeparatedByString("/").last!
    }
    // MARK: - 长度
    public var length:Int {
        return distance(startIndex, endIndex)
    }
    
    // MARK: - 字符串截取
    public func substringToIndex(index:Int) -> String {
        return self.substringToIndex(advance(self.startIndex, index))
    }
    public func substringFromIndex(index:Int) -> String {
        return self.substringFromIndex(advance(self.startIndex, index))
    }
    public func substringWithRange(range:Range<Int>) -> String {
        let start = advance(self.startIndex, range.startIndex)
        let end = advance(self.startIndex, range.endIndex)
        return self.substringWithRange(start..<end)
    }
    
    public subscript(index:Int) -> Character{
        return self[advance(self.startIndex, index)]
    }
    
    public subscript(subRange:Range<Int>) -> String {
        return self[advance(self.startIndex, subRange.startIndex)..<advance(self.startIndex, subRange.endIndex)]
    }
    
    // MARK: - 字符串修改 RangeReplaceableCollectionType
    public mutating func insert(newElement: Character, atIndex i: Int) {
        insert(newElement, atIndex: advance(self.startIndex,i))
    }
    
    public mutating func splice<S : CollectionType where S.Generator.Element == Character>(newElements: S, atIndex i:Int) {
        splice(newElements, atIndex: advance(self.startIndex,i))
    }
    
    public mutating func replaceRange(subRange: Range<Int>, with newValues: String) {
        let start = advance(self.startIndex, subRange.startIndex)
        let end = advance(self.startIndex, subRange.endIndex)
        replaceRange(start..<end, with: newValues)
    }
    
    public mutating func removeAtIndex(i: Int) -> Character {
        return removeAtIndex(advance(self.startIndex,i))
    }
    
    public mutating func removeRange(subRange: Range<Int>) {
        let start = advance(self.startIndex, subRange.startIndex)
        let end = advance(self.startIndex, subRange.endIndex)
        removeRange(start..<end)
    }
    
    // MARK: - 字符串拆分
    public func separatedByString(separator: String) -> [String] {
        return self.componentsSeparatedByString(separator)
    }
    public func separatedByCharacters(separators: String) -> [String] {
        return self.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: separators))
    }
    
    // MARK: - URL解码/编码
    
    /// 给URL解编码
    public func decodeURL() -> String! {
        let str:NSString = self
        return str.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
    }
    
    /// 给URL编码
    public func encodeURL() -> String {
        let originalString:CFStringRef = self as NSString
        let charactersToBeEscaped = "!*'();:@&=+$,/?%#[]" as CFStringRef  //":/?&=;+!@#$()',*"    //转意符号
        //let charactersToLeaveUnescaped = "[]." as CFStringRef  //保留的符号
        let result =
        CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
            originalString,
            nil,    //charactersToLeaveUnescaped,
            charactersToBeEscaped,
            CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)) as NSString
        
        return result as String
    }
    
}

extension String.UnicodeScalarView {
    public subscript (i: Int) -> UnicodeScalar {
        return self[advance(self.startIndex, i)]
    }
}


/// trim 去掉字符串两段的换行与空格
extension String {
    public enum TrimMode : Int {
        case Both
        case Prefix
        case Suffix
    }
    
    public func trim(mode:TrimMode = .Both) -> String {
        var start:Int = 0
        switch mode {
        case .Both:
            return self.trim(.Prefix).trim(.Suffix)
        case .Prefix:
            for char:Character in characters {
                switch char {
                    case " ", "\n", "\r":
                    start++
                default:
                    return substringFromIndex(start)
                }
            }
        case .Suffix:
            let chars = characters.reverse()
            for char:Character in chars {
                switch char {
                case " ", "\n", "\r":
                    start++
                default:
                    return substringToIndex(chars.count - start)
                }
            }
        }
        return ""
    }
}

/*
extension NSURL: StringLiteralConvertible {
public class func convertFromExtendedGraphemeClusterLiteral(value: String) -> Self {
return self(string: value)
}

public class func convertFromStringLiteral(value: String) -> Self {
return self(string: value)
}
}
*/