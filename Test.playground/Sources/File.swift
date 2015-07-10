import Foundation

public func ==(lhs:File, rhs:File) -> Bool { return lhs.fullPath == rhs.fullPath }

public struct File : Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    
    // MARK: - CustomStringConvertible
    public var description: String { return fullPath.stringByDeletingPathPrefix }
    
    // MARK: - CustomDebugStringConvertible
    public var debugDescription: String { return fullPath }
    
    // MARK: - File init
    public init(fullPath:String) {
        setPath(fullPath)
    }
    public init(rootPath:String, fileName:String) {
        setPath(rootPath.stringByAppendingPathComponent(fileName))
    }
    public init(rootFile:File, fileName:String) {
        setPath(rootFile.fullPath.stringByAppendingPathComponent(fileName))
    }
    private mutating func setPath(path:String) {
        self.fullPath = path
    }
    
    // MARK: 文件属性
    private var _fileAttributes:[String : AnyObject]?
    public var fileAttributes:[String : AnyObject] { return _fileAttributes ?? [:] }
    
    // MARK: 文件路径
    public var fullPath:String = "" {
        didSet {
            do {
                _fileAttributes = try NSFileManager.defaultManager().attributesOfItemAtPath(fullPath)
            } catch {}
        }
    }
    
    // MARK: 文件大小
    public var fileSize:UInt64 {
        let size:NSNumber? = fileAttributes[NSFileSize] as? NSNumber
        return size?.unsignedLongLongValue ?? 0
    }
    
    // MARK: 判断目录中存在指定 1-n个文件名
    public func existsFileName(var names:[String]) -> Bool {
        if names.count == 0 { return false }
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        do {
            let fileNames:[String] = try fileManager.contentsOfDirectoryAtPath(fullPath)
            for fileName in fileNames {
                if names.count == 0 { break }
                let index = names.indexOf() { $0 == fileName }
                if index != NSNotFound { names.removeAtIndex(index) }
            }
            return names.count == 0
        } catch {}
        return false
    }
    
    // MARK: 文件名
    public var fileName:String { return fullPath.stringByDeletingPathPrefix }
    
    // MARK: 文件状态
    public var isExecutable:Bool { return NSFileManager.defaultManager().isExecutableFileAtPath(fullPath) }
    public var isDeletable:Bool { return NSFileManager.defaultManager().isDeletableFileAtPath(fullPath) }
    public var isDirectory:Bool {
        var directory:ObjCBool = false
        NSFileManager.defaultManager().fileExistsAtPath(fullPath, isDirectory: &directory)
        return directory.boolValue
    }
    public var isExists:Bool { return NSFileManager.defaultManager().fileExistsAtPath(fullPath) }
    
    // MARK: 所有子文件
    public var subFileList:[File] {
        var files:[File] = []
        let fileManager:NSFileManager = NSFileManager.defaultManager()
        do {
            let fileNames:[String] = try fileManager.contentsOfDirectoryAtPath(fullPath)
            for fileName in fileNames {
                files.append(File(rootPath: fullPath, fileName: fileName))
                fullPath.stringByDeletingPathExtension
            }
        } catch {}
        return files
    }
    public var fileExtension:String {
        return fileName.componentsSeparatedByString(".").last ?? ""
    }
    
    // MARK: - 系统默认文件路径
    public static func systemDirectory(pathType:NSSearchPathDirectory, domainMask:NSSearchPathDomainMask = .UserDomainMask) -> File {
        let path = NSSearchPathForDirectoriesInDomains(pathType, domainMask, true)[0]
        return File(fullPath: path)
    }
    
    public static var documentDirectory:File { return systemDirectory(.DocumentDirectory) }
    public static var downloadDirectory:File { return systemDirectory(.DownloadsDirectory) }
    public static var cacheDirectory:File { return systemDirectory(.CachesDirectory) }

    public static func homeDirectoryForUser(userName:String) -> File {
        if let path = NSHomeDirectoryForUser(userName) {
            return File(fullPath: path)
        }
        return File(fullPath: NSHomeDirectory())
    }
    public static var homeDirectory:File { return File(fullPath: NSHomeDirectory()) }
    public static var temporaryDirectory:File { return File(fullPath: NSTemporaryDirectory()) }
    public static var openStepRootDirectory:File { return File(fullPath: NSOpenStepRootDirectory()) }
    public static var fullUserName:String { return NSFullUserName() }
    public static var userName:String { return NSUserName() }
}