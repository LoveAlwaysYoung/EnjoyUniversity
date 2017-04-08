//
//  EUNetworkManager+Extension.swift
//  EnjoyUniversity
//
//  Created by lip on 17/3/28.
//  Copyright © 2017年 lip. All rights reserved.
//

// MARK: - 封装具体的网络接口
import Alamofire


// MARK: - 读取接口
extension EUNetworkManager{
    
    
    /// 根据手机号获取验证码
    ///
    /// - Parameters:
    ///   - phone: 手机号
    ///   - isLogin: 是否用于登陆（还可能用于忘记密码）
    ///   - completion: 请求是否成功，验证码
    func getVerificationCode(phone:String,isLogin:Bool,completion:@escaping (Bool,String?)->()){
        
        let url = SERVERADDRESS + "/eu/user/verifyphone"
        var para = Parameters()
        para["phone"] = phone
        para["choice"] = isLogin ? 0 : 1
        
        request(urlString: url, method: .post, parameters: para) { (code, isSuccess,statusCode) in
            
            if !isSuccess{
                completion(false, nil)
                return
            }
            
            guard let code = code as? String else {
                completion(true,nil)
                return
            }
            if statusCode == 200 {
                completion(true, code)
                return
            }
            completion(true,nil)
            return
        }
        
    }
    
    /// 通过帐号密码登陆
    ///
    /// - Parameters:
    ///   - password: 用户密码
    ///   - completion: 请求是否成功，登陆是否成功
    func loginByPassword(phone:String,password:String,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/user/login"
        
        var parm = Parameters()
        parm["uid"] = phone
        parm["password"] = password
        
        request(urlString: url, method: .post, parameters: parm) { (token, isSuccess,statusCode) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            
            /// 400 表示用户名或密码错误
            if statusCode == 400{
                completion(true,false)
                return
            }
        
            guard let token = token as? String else{
                completion(true,false)
                return
            }
            
            let uid = Int(phone) ?? 0
            let dict = ["uid":uid,"accesstoken":token] as [String : Any]
            self.userAccount.yy_modelSet(with: dict)
            self.userAccount.saveToUserDefaults(dict: dict)
            completion(true,true)
        }
        
    }
    

    
    /// 获取 ViewPager
    func getViewPagers(completion:@escaping (Any?,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/viewpager/show"
        
        request(urlString: url, parameters: nil) { (json, isSuccess,_) in
            completion(json, isSuccess)

        }
        
    }
    
    /// 获取社团数据 注意：page的0和1一样
    func getCommunityList(page:Int = 1,rows:Int = EUREQUESTCOUNT,completion:@escaping ([[String:Any]]?,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/commoncm"
        
        var paramters = Parameters()
        
        paramters["page"] = page
        paramters["rows"] = rows
        
        request(urlString: url, parameters: paramters) { (json, isSuccess,_) in
            
            let array = json as? [[String:Any]]
            completion(array, isSuccess)
            
        }
        
    }
    
    /// 获取活动数据
    func getActivityList(mintime:String?,maxtime:String?,count:Int = EUREQUESTCOUNT,completion:@escaping ([[String:Any]]?,Bool)->()){
     
        let url = SERVERADDRESS + "/eu/activity/commonav"
        
        var parameters = Parameters()
        parameters["count"] = count
        
        if let mintime = mintime {
            parameters["mintime"] = mintime
        }
        
        if let maxtime = maxtime {
            parameters["maxtime"] = maxtime
        }
        
        request(urlString: url, parameters: parameters) { (json, isSuccess,_) in
            guard let array = json as? [[String:Any]] else{
                completion(nil, false)
                return
            }
            completion(array,true)
        }
        
    }
    
    /// 获取我参加的活动数据
    func getParticipatedActivityList(completion:@escaping ([[String:Any]]?,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/activity/joinedav"
        
        var parameters = Parameters()
        
        parameters["uid"] = userAccount.uid
        
        tokenRequest(urlString: url, method: .post, parameters: parameters) { (json, isSuccess,_) in
            
            guard let array = json as? [[String:Any]] else{
                completion(nil,false)
                return
            }
            completion(array,true)
            
        }
        
        
    }
    
    /// 获取我创建的活动数据
    func getCreatedActivityList(completion:@escaping ([[String:Any]]?,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/activity/createdav"
        
        var parameters = Parameters()
        parameters["uid"] = userAccount.uid
        
        tokenRequest(urlString: url, method: .post, parameters: parameters) { (json, isSuccess,_) in
            
            guard let array = json as? [[String:Any]] else{
                completion(nil,false)
                return
            }
            completion(array,true)
            
        }
        
        
    }
    

}

// MARK: - 写入接口
extension EUNetworkManager{
    
    /// 短信验证码修改用户密码
    func changgePasswordByVerifyCode(phone:String,newpwd:String,completion:@escaping (Bool)->()){
        
        let url = SERVERADDRESS + "/eu/user/changepwdbyphone"
        
        var parm = Parameters()
        parm["uid"] = phone
        parm["newpwd"] = newpwd
        
        request(urlString: url, method: .post, parameters: parm) { (json, isSuccess,_) in
            if !isSuccess {
                completion(false)
                return
            }
            
            guard let dict = json as? [String:Any],let accesstoken = dict["accesstoken"] as? String else {
                completion(false)
                return
            }
            let userdict = ["uid":phone,"accesstoken":accesstoken]
            
            self.userAccount.saveToUserDefaults(dict: userdict)
            completion(true)
        }
        
    }
    
    
    /// 创建活动
    func releaseActivity(activity:Activity,completion:@escaping (Bool)->()){
        
        let url = SERVERADDRESS + "/eu/activity/createav"
        
        var parameters = Parameters()
        
        parameters["uid"] = userAccount.uid
        parameters["avTitle"] = activity.avTitle
        parameters["avDetail"] = activity.avDetail
        parameters["avPlace"] = activity.avPlace
        parameters["avPrice"] = activity.avPrice
        parameters["avExpectnum"] = activity.avExpectnum
        parameters["avstarttime"] = activity.avStarttime
        parameters["avendtime"] = activity.avEndtime
        parameters["avenrolldeadline"] = activity.avEnrolldeadline
        parameters["avRegister"] = activity.avRegister
        parameters["avLogo"] = activity.avLogo
        
        
        tokenRequest(urlString: url, method: .post, parameters: parameters) { (json, isSuccess,_) in
            
            if !isSuccess{
                completion(false)
                return
            }
            guard let array = json as? [String:Any] else{
                completion(false)
                return
            }
            
            if let status = array["status"] as? Int {
                
                if status == 200{
                    
                    completion(true)
                }else{
                    completion(false)
                }
                return
                
            }
            
        }
        
    }

}

// MARK: - 上传接口
extension EUNetworkManager{
    
    /// 上传图片到服务器
    ///
    /// - Parameters:
    ///   - uploadimg: 需要上传的图片
    ///   - completion: 完成回调（是否成功，图片地址）
    func uploadActivityLogo(uploadimg:UIImage,completion:@escaping (Bool,String?)->()){
        
        let url = SERVERADDRESS + "/eu/upload/activity"
        
        //将选择的图片保存到Document目录下
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let filePath = "\(rootPath)/pickedimage.jpg"
        let imageData = UIImageJPEGRepresentation(uploadimg, 1.0)
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        //上传图片
        if (fileManager.fileExists(atPath: filePath)){

            Alamofire.upload(multipartFormData: { (multipartdata) in
                
                multipartdata.append(URL(fileURLWithPath: filePath), withName: "file")
                
            }, to: url, encodingCompletion: { (encodingResult) in
                
                // 接受从服务器返回的参数
                switch encodingResult {
                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                    upload.responseJSON(completionHandler: { (json) in
                        
                        let dict = json.result.value as? [String:Any] ?? [:]
                        let address = dict["data"] as? String
                        completion(true, address)
                    })
                    break
                case .failure( _):
                    completion(false,nil)
                    break
                    
                }
            })
            
        }
        
    }
    
}
