//
//  Networking.swift
//  Test
//
//  Created by 隋冬阳 on 2023/9/6.
//

import Foundation
import Alamofire

class Networking: NSObject {
    
    @objc static func getWeather(_ adcode: String = "110000",
                                 success: @escaping (String) -> Void,
                                 fail: @escaping (String) -> Void) {
        
        let url = "https://restapi.amap.com/v3/weather/weatherInfo?key=8c06fcd9c28dd8e19b1dae401643d9c7&city=" + adcode
        
        AF.request(url, method: .get).response { response in
            
            debugPrint(response)
            
            if let code = response.response?.statusCode {
                if code != 200 {
                    fail("请求失败 \(code)")
                    return
                }
            }
            
            if let data = response.data {
                
                do {
                    let obj = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                    if let weather: [String: Any] = (obj["lives"] as? [AnyObject])?.first as? [String: Any] {
                        let desc = "\(weather["weather"] ?? "")，\(weather["temperature"] ?? "")度，\(weather["winddirection"] ?? "")风"
                        success(desc)
                    }
                    
                    print("");
                } catch {
                    print("数据解析失败")
                }
            }
        }
    }
}

/*
 {
     "status":"1",
     "count":"1",
     "info":"OK",
     "infocode":"10000",
     "lives":[
         {
             "province":"北京",
             "city":"北京市",
             "adcode":"110000",
             "weather":"多云",
             "temperature":"31",
             "winddirection":"西北",
             "windpower":"≤3",
             "humidity":"57",
             "reporttime":"2023-09-06 15:33:39",
             "temperature_float":"31.0",
             "humidity_float":"57.0"
         }
     ]
 }
 */
