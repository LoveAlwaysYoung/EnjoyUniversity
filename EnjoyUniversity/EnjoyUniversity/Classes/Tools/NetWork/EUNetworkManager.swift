//
//  EUNetworkManager.swift
//  EnjoyUniversity
//
//  Created by lip on 17/3/28.
//  Copyright © 2017年 lip. All rights reserved.
//

import Foundation
import Alamofire


class EUNetworkManager{
    
    var accessToken:String? = "06e2a69c-eea0-4e82-a633-5e66eefc5bb6"
    
    // 创建单例
    static let shared = EUNetworkManager()
    
    
    /// 封装网络请求
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - method: 请求方式，默认 GET 方式
    ///   - parameters: 请求参数
    ///   - completion: 完成回调
    func request(urlString:String,method:HTTPMethod = .get,parameters:Parameters?,completion:@escaping (Any?,Bool)->())  {

        
        
        let request = Alamofire.request(urlString, method:method, parameters: parameters, encoding: URLEncoding.default, headers: nil)
        
        print("请求网址:\(request)")
        
        request.responseJSON { (response) in
            
            if response.result.isSuccess {
                let json = response.result.value
                completion(json, true)
            }else{
                
                //FIXME: 处理错误信息 服务器端针对 Token 错误应该返回 403 ，通过 403 通知用户重新登录
                completion(nil, false)
                
            }

        }
    }
    
    
    /// 带有 Access Token 的请求
    ///
    /// - Parameters:
    ///   - urlString: 请求地址
    ///   - method: 请求方式
    ///   - parameters: 请求参数 ［Sting:Any］类型
    ///   - completion: 完成回调
    func tokenRequest(urlString:String,method:HTTPMethod = .get,parameters:Parameters?,completion:@escaping (Any?,Bool)->()){
        
        // 判断 Token 是否存在，不存在则不做请求
        guard let token = accessToken else {
            completion(nil, false)
            return
        }
        
        var parameters = parameters
        
        if parameters == nil{
            parameters = Parameters()
        }
        
        parameters!["accesstoken"] = token 
        
        request(urlString: urlString, method: method, parameters: parameters, completion: completion)
        
        
    }
    
}