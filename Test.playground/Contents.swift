//: Playground - noun: a place where people can play

import Cocoa

var str = "\t Hello, playground \r\n"
let m:Character = "\u{65}\u{301}\u{20DD}"



let duihao:Character = "\u{382}\u{20DE}"

var tttt = str.trim()
print(tttt)


let json = "{\"icon\":\"1\",\"subject_name\":\"护士专业实物与实践能力\",\"subject_id\":204,\"subject_pid\":203,\"children\":[],\"software_type_value\":16,\"subject_remark\":\"护士专业实物与实践能力\",\"leaf\":true,\"expanded\":\"\",\"subject_take\":1,\"update_time\":\"2015-08-19 13:43:54.0\",\"subject_no\":0,\"subject_type\":1,\"checked\":false}"

if let data = json.jsonParseToDictionary().dict {
    let id = data["subject_id"] ?? 0
}

