import Foundation

// MARK: - http 应答结果
public class HttpState {
    public var state:Int = 0
    public var error:NSError?
    public var timestamp:NSTimeInterval = 0
}

public class HttpResponse:HttpState {
    public var content:String = ""

}

public class HttpDownload:HttpState {
    public var totalSize:Int64 = 0
    public var localSize:Int64 = 0
    public var localPath:String = ""
}

// MARK: - http 网络访问
public class HttpRequest {
    
    public typealias OnHttpRequestComplete = (HttpResponse) -> Void
    public typealias OnHttpRequestDownload = (HttpDownload) -> Void
    
    private let _url:NSURL
    public var url:NSURL { return _url }
    public var post:[String:String]?
    public var headers:[String:String]?
    public var timeout:NSTimeInterval = 15
    
    public init(URL url:NSURL, post:[String:String]?, headers:[String:String]?, timeout:NSTimeInterval = 15) {
        self._url = url
        self.post = post
        self.headers = headers
        self.timeout = timeout
    }
    
    public convenience init(URL url:NSURL) {
        self.init(URL:url, post:nil, headers:nil)
    }
    
    public convenience init(URL url:NSURL, timeout:NSTimeInterval) {
        self.init(URL:url, post:nil, headers:nil, timeout:timeout)
    }
    
    public convenience init(URL url:NSURL, post:[String:String]?) {
        self.init(URL:url, post:post, headers:nil)
    }
    
    public convenience init(URL url:NSURL, post:[String:String]?, timeout:NSTimeInterval) {
        self.init(URL:url, post:post, headers:nil, timeout:timeout)
    }
    
    class ConnectObject : NSObject, NSURLConnectionDelegate {
        var onStop:() -> Void
        init (onStop:() -> Void) {
            self.onStop = onStop
        }

        var connection:NSURLConnection? = nil
        var receiveData:NSMutableData? = nil
        
        var onComplete:OnHttpRequestComplete?
        var onDownload:OnHttpRequestDownload?
        
        var isCancel:Bool = false

        func cancel() {
            isCancel = true
            connection?.cancel()
        }
        
        //接收到服务器回应的时候调用此方法
        func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse) {
            //let httpResponse = response as NSHTTPURLResponse
            receiveData = NSMutableData()
            if let onDownloadOver = onDownload {
                let path = connection.currentRequest.URL!. downloadCachePathWithURL(connection.currentRequest.URL!)

            }
            if let onDownloadComplete = onDownloadOver {
                let path = downloadCachePathWithURL(connection.currentRequest.URL!)
                if let data = NSData(contentsOfFile: path + ".download") {
                    receiveData!.appendData(data)
                }
                if let res = response as? NSHTTPURLResponse {
                    let length = res.allHeaderFields["Content-Length"] as! NSString
                    topbytes = UInt64(length.longLongValue)
                }
                onDownloadComplete(topbytes: topbytes, data: receiveData, error: nil, finishPath: nil)
            }
        }
        
        //接收到服务器传输数据的时候调用，此方法根据数据大小执行若干次
        func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
            if receiveData == nil {
                receiveData = NSMutableData()
            }
            //receiveData!.appendData(data)
            if let onDownloadComplete = onDownloadOver {
                if fileHandle == nil {
                    let path = downloadCachePathWithURL(connection.currentRequest.URL!)
                    fileHandle = NSFileHandle(forWritingAtPath: path + ".download")
                }
                fileHandle.seekToEndOfFile()
                fileHandle.writeData(data)
                onDownloadComplete(topbytes: topbytes, data: receiveData, error: nil, finishPath: nil)
            }
            
            if let receive = receiveData {
                receive.appendData(data)
            } else {
                receiveData = NSMutableData()
                receiveData!.appendData(data)
            }
        }
        
        //数据传完之后调用此方法
        func connectionDidFinishLoading(connection: NSURLConnection!) {
            self.connection = nil
            // 如果是Http访问
            if let complete = onHttpOver {
                let html:String = NSString(data: receiveData!, encoding: NSUTF8StringEncoding)! as String
                complete(html: html,error: nil)
                onHttpOver = nil
            }
            // 如果是Http下载
            if let onDownloadComplete = onDownloadOver {
                
                if let handle = fileHandle {
                    handle.closeFile()
                    fileHandle = nil
                }
                
                let url = connection.currentRequest.URL!
                let path = downloadCachePathWithURL(url)
                
                let fileManager = NSFileManager.defaultManager()
                do {
                    try fileManager.moveItemAtPath(path + ".download", toPath: path)
                } catch {}
                
                
                onDownloadOver = nil
                topbytes = 0
                onDownloadComplete(topbytes: topbytes, data: receiveData, error: nil, finishPath: path)
            }
            receiveData = nil
        }
        
        //网络请求过程中，出现任何错误（断网，连接超时等）会进入此方法
        func connection(connection: NSURLConnection, didFailWithError error: NSError) {
            self.connection = nil
            // 如果是Http访问
            if let complete = onHttpOver {
                complete(html: "",error: error)
                onHttpOver = nil
            }
            // 如果是Http下载
            if let onDownloadComplete = onDownloadOver {
                
                if let handle = fileHandle {
                    handle.closeFile()
                    fileHandle = nil
                }
                
                
                onDownloadOver = nil
                topbytes = 0
                onDownloadComplete(topbytes: topbytes, data: receiveData, error: error, finishPath: nil)
                
            }
            receiveData = nil
        }
    }
    
    private class func getURLRequest(http:HttpRequest) -> NSMutableURLRequest {
        let request:NSMutableURLRequest = NSMutableURLRequest(URL: http.url, cachePolicy: .UseProtocolCachePolicy, timeoutInterval: http.timeout)
        
        request.HTTPMethod = "GET"
        if let datas = http.post where datas.count > 0 {
            request.HTTPMethod = "POST"
            var postString = ""
            for (key, value) in datas {
                if !postString.isEmpty {
                    postString += "&"
                }
                postString += "\(key.encodeURL())=\(value.encodeURL())"
            }
            let data:NSData = postString.dataUsingEncoding(NSUTF8StringEncoding)!
            
            request.HTTPBody = data;
            request.setValue("\(data.length)", forHTTPHeaderField: "Content-Length")
            if let httpHeaders = http.headers {
                for (header, value) in httpHeaders {
                    request.setValue(value, forHTTPHeaderField: header)
                }
            }
        }
        return request
    }
    
    var isConnecting:Bool { !(_connect?.isCancel ?? true) }

    private var _connect:ConnectObject?
    public func send(onComplete:OnHttpRequestComplete) {
        if _connect != nil {
            _connect!.cancel()
        }
        let connect = ConnectObject() { self._connect = nil }
        connect.onComplete = onComplete
        
        let request:NSMutableURLRequest = HttpRequest.getURLRequest(self)
        
        //连接服务器
        _connect = connect
        connect.connection = NSURLConnection(request: request, delegate: connect)

    }
    
}