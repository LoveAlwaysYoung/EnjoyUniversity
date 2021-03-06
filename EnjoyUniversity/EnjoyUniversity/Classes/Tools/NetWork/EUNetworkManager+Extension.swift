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
    ///   - isRegister: 是否用于登陆（还可能用于忘记密码）
    ///   - completion: 请求是否成功，验证码
    func getVerificationCode(phone:String,isRegister:Bool,completion:@escaping (Bool,String?)->()){
        
        let url = SERVERADDRESS + "/eu/user/verifyphone"
        var para = Parameters()
        para["phone"] = phone
        para["choice"] = isRegister ? 0 : 1
        
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
            
            /// 401 表示用户名或密码错误
            if statusCode == 401{
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
        
        request(urlString: url, method: .post, parameters: paramters) { (json, isSuccess, _) in
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
    
    /// 获取其它用户信息
    ///
    /// - Parameters:
    ///   - uid: 用户手机号
    ///   - completion: 完成回调 是否请求成功，用户信息字典
    func getUserInfomation(uid:Int64,completion:@escaping(Bool,[String:Any]?)->()){
        
        let url = SERVERADDRESS + "/eu/info/introinfo"
        
        let parm = ["uid":uid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (dict, isSuccess, _) in
            
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let dict = dict as? [String:Any] else{
                completion(false,nil)
                return
            }
            completion(true,dict)
        }
        
    }
    
    /// 获取参与活动的用户列表
    ///
    /// - Parameters:
    ///   - avid: 活动 ID
    ///   - choice: 选择加载的用户列表 0所有参加活动的用户 1完成签到的用户 －1未完成签到的用户
    ///   - completion: 完成回调
    func getActivityParticipators(avid:Int,choice:Int = 0,completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/activity/memberinfolist"
        
        let parm = ["avid":avid,"choice":choice]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
            
        }
    }
    
    
    /// 获取用户个人信息
    ///
    /// - Parameter completion: 完成回调
    func getUserPrivateInfo(completion:@escaping(Bool,UserinfoViewModel?)->()){
        
        let url = SERVERADDRESS + "/eu/info/userinfo"
        
        let parm = ["uid":userAccount.uid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (dict, isSuccess, code) in
            
            if !isSuccess{
             
                completion(false, nil)
                return
            }
            
            if code == 401 {
                completion(true,nil)
                return
            }
            
            guard let dict = dict as? [String:Any], let userinfo = UserInfo.yy_model(with: dict) else {
                completion(true,nil)
                return
            }
            
            completion(true,UserinfoViewModel(model: userinfo))
            
        }
        
    }
    
    
    /// 根据活动 ID 获取活动信息
    ///
    /// - Parameters:
    ///   - avid: 活动 ID
    ///   - completion: 是否成功，视图模型
    func getActivityInfoByID(avid:Int,completion:@escaping (Bool,ActivityViewModel?)->()){
        
        let url = SERVERADDRESS + "/eu/activity/getactivity"
        
        let parm = ["avid":avid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (dict, isSuccess, _) in
            
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let dict = dict as? [String:Any], let activity = Activity.yy_model(with: dict) else{
                completion(true,nil)
                return
            }
            completion(true,ActivityViewModel(model: activity))
        }
        
    }
    
    /// 根据社团 ID 获取社团信息
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - completion: 是否成功，视图模型
    func getCommunityInfoByID(cmid:Int,completion:@escaping (Bool,CommunityViewModel?)->()){
        
        let url = SERVERADDRESS + "/eu/community/getcommunity"
        
        let parm = ["cmid":cmid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (dict, isSuccess, _) in
            
            if !isSuccess{
                completion(false, nil)
                return
            }
            guard let dict = dict as? [String:Any],let community = Community.yy_model(with: dict) else{
                completion(true,nil)
                return
            }
            completion(true,CommunityViewModel(model: community))
        }
        
    }
    
    /// 获取用户参加的社团列表
    ///
    /// - Parameter completion: 完成回调
    func getCommunityNameList(completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/community/mycommunitylist"
        
        let parm = ["uid":userAccount.uid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, status) in
            
            if !isSuccess{
                completion(false,nil)
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
    }
    
    /// 获取社团成员列表
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - completion: 完成回调
    func getCommunityMemberList(cmid:Int,completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/community/memberlist"
        
        let parm = ["cmid":cmid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
    }
    
    /// 获取我收藏的活动
    ///
    /// - Parameter completion: 完成回调
    func getMyActivityCollection(completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/activity/collectedav"
        
        let parm = ["uid":userAccount.uid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
    }
    
    /// 获取我收藏的社团
    ///
    /// - Parameter completion: 完成回调
    func getMyCommunityCollection(completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/community/collectedcm"
        
        let parm = ["uid":userAccount.uid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
        
    }
    
    /// 获取社团通讯录
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - completion: 完成回调
    func getCommunityContactsByID(cmid:Int,completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/community/contacts"
        
        let parm = ["cmid":cmid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
    }
    
    /// 获取社团成员列表信息
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - completion: 完成回调
    func getCommunityMemberInfoList(cmid:Int,completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/community/memberinfolist"
        
        let parm = ["cmid":cmid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
    }
    
    /// 搜索 活动／社团／用户 数量
    ///
    /// - Parameters:
    ///   - keyword: 关键字
    ///   - compeltion: 完成回调
    func getSearchNum(keyword:String,compeltion:@escaping (Bool,[String:Int]?)->()){
        
        let url = SERVERADDRESS + "/eu/common/searchnum"
        
        let parm = ["keyword":keyword]
        
        request(urlString: url, method: .post, parameters: parm) { (dict, isSuccess, _) in
            
            if !isSuccess{
                compeltion(false,nil)
                return
            }
            guard let dict = dict as? [String:Int] else{
                compeltion(true,nil)
                return
            }
            compeltion(true,dict)
        }
        
    }
    
    /// 搜索活动
    ///
    /// - Parameters:
    ///   - keyword: 关键字
    ///   - completion: 完成回调
    func searchActivity(keyword:String,page:Int,rows:Int,completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/activity/search"
        
        let parm = ["keyword":keyword,"page":page,"rows":rows] as [String:Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
    }
    
    /// 搜索社团
    ///
    /// - Parameters:
    ///   - keyword: 关键字
    ///   - page: 页
    ///   - rows: 每页行数
    ///   - completion: 完成回调
    func searchCommunity(keyword:String,page:Int,rows:Int,completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/community/search"
        
        let parm = ["keyword":keyword,"page":page,"rows":rows] as [String:Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
    }
    
    /// 搜索用户
    ///
    /// - Parameters:
    ///   - keyword: 关键词
    ///   - page: 页
    ///   - rows: 每页行数
    ///   - completion: 完成回调
    func searchUser(keyword:String,page:Int,rows:Int,completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/info/search"
        
        let parm = ["keyword":keyword,"page":page,"rows":rows] as [String:Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
    }
    
    /// 获取 3 个消息的第一条
    ///
    /// - Parameter completion: 完成回调
    func getNotificationLite(completion:@escaping (Bool,[String:String]?)->()){
        
        let url = SERVERADDRESS + "/eu/notification/msglite"
        
        let parm = ["uid":userAccount.uid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (dict, isSuccess, _) in
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let dict = dict as? [String:String] else{
                completion(true,nil)
                return
            }
            completion(true,dict)
        }
    }
    
    /// 获取活动通知
    ///
    /// - Parameter completion: 完成回调
    func getActivityNotifications(completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/notification/activity"
        
        let parm = ["uid":userAccount.uid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
    }
    
    /// 获取社团通知
    ///
    /// - Parameter completion: 完成回调
    func getCommunityNotifications(completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/notification/community"
        
        let parm = ["uid":userAccount.uid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (json, isSuccess, _) in
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
        }
    }
    
    /// 获取系统通知
    ///
    /// - Parameter completion: 完成回调
    func getSystemNotifications(completion:@escaping (Bool,[[String:Any]]?)->()){
        
        let url = SERVERADDRESS + "/eu/notification/system"
        
        tokenRequest(urlString: url, method: .post, parameters: nil) { (json, isSuccess, _) in
            if !isSuccess{
                completion(false,nil)
                return
            }
            guard let json = json as? [[String:Any]] else{
                completion(true,nil)
                return
            }
            completion(true,json)
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
            
            guard let accesstoken = json as? String else {
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
        
        
        tokenRequest(urlString: url, method: .post, parameters: parameters) { (_, _,code) in
            

            if code == 200{
                completion(true)
                return
            }
            completion(false)
        }
    }
    
    /// 修改活动
    ///
    /// - Parameters:
    ///   - activity: 活动
    ///   - completion: 完成回调(网络请求是成功,是否有权限修改)
    func changeActivity(activity:Activity,completion:@escaping (Bool,Bool)->()){

        let url = SERVERADDRESS + "/eu/activity/changeav"
        
        var parameters = Parameters()
        parameters["avid"] = activity.avid
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
        
        tokenRequest(urlString: url, method: .post, parameters: parameters) { (_, isSuccess, status) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 401{
                completion(true,false)
                return
            }
            completion(true,true)
        }
        
    }
    
    /// 创建用户(注册成功)
    func createUser(user:UserInfo,password:String,completion:@escaping (Bool)->()){
        
        let url = SERVERADDRESS + "/eu/user/newuser"
        
        var parm = Parameters()
        
        parm["password"] = password
        parm["uid"] = user.uid
        parm["avatar"] = user.avatar
        parm["gender"] = user.gender
        parm["nickname"] = user.nickname
        parm["professionclass"] = user.professionclass
        parm["name"] = user.name
        parm["studentid"] = user.studentid
        
        parm["reputation"] = 100
        parm["verified"] = 0
        
        request(urlString: url, method: .post, parameters: parm) { (token, isSuccess, _) in
            
            if !isSuccess{
                completion(false)
                return
            }
            
            guard let token = token else{
                completion(false)
                return
            }
            
            let userdict = ["uid":user.uid,"accesstoken":token]
            
            self.userAccount.uid = user.uid
            self.userAccount.accesstoken = token as? String
            self.userAccount.saveToUserDefaults(dict: userdict)
            completion(true)
            
        }
    }
    
    /// 收藏活动
    ///
    /// - Parameters:
    ///   - avid: 活动 ID
    ///   - completion: 完成回调,请求是否成功，收藏是否成功
    func collectActivity(avid:Int,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/activity/collectav"
        
        var parm = Parameters()
        
        parm["uid"] = userAccount.uid
        parm["avid"] = avid
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, code) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            
            if code == 500{
                completion(true,false)
                return
            }
            
            completion(true,true)
            
        }
        
    }
    
    /// 参加活动
    ///
    /// - Parameters:
    ///   - avid: 活动 ID
    ///   - verifystate: 是否需要签到
    ///   - completion: 活动 ID ，完成回调(请求是否成功，参加是否成功)
    func participateActivity(avid:Int,needregist:Bool,completion:@escaping (Bool,Bool)->()){
        
        
        let url = SERVERADDRESS + "/eu/activity/participateav"
        
        let verifystate = needregist ? 0 : 2
        
        let parm = ["uid":userAccount.uid,"avid":avid,"verifystate":verifystate] as [String : Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
        
            if !isSuccess{
             
                completion(false,false)
                return
            }
            
            if status == 500{
                completion(true,false)
                return
            }
            
            completion(true,true)
        }
        
    }
    
    
    /// 退出活动
    ///
    /// - Parameters:
    ///   - avid: 活动 ID
    ///   - completion: 完成回调（网络请求是否成功，是否退出活动）
    func leaveActivity(avid:Int,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/activity/quitav"
        
        let parm = ["uid":userAccount.uid,"avid":avid] as [String : Any]
        
        tokenRequest(urlString: url, method: .post,  parameters: parm) { (_, isSuccess, status) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            
            if status == 500{
                completion(true,false)
                return
            }
            
            completion(true,true)

        }
    }
    
    /// 拒绝某人参加活动
    ///
    /// - Parameters:
    ///   - uid: 被拒绝者 ID
    ///   - avid: 活动 ID
    ///   - reason: 被拒绝原因
    ///   - completion: 完成回调（网络请求是否成功，拒绝是否成功）
    func removeSomeOneFromMyActovoty(uid:Int64,avid:Int,reason:String?,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/activity/manage"
        
        var parm = Parameters()
        
        parm["uid"] = uid
        parm["avid"] = avid
        parm["verifystate"] = -1
        parm["reason"] = reason
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            
            if status == 500{
                completion(true,false)
                return
            }
            completion(true,true)
            
        }
    }
    
    /// 发起活动签到
    ///
    /// - Parameters:
    ///   - avid: 活动 ID
    ///   - uid: 活动创建人 ID
    ///   - completion: 网络请求是否成功，发起签到是否哦成功（权限问题），签到码
    func startActivityRegist(avid:Int,completion:@escaping (Bool,Bool,String?)->()){
        
        let url = SERVERADDRESS + "/eu/activity/startregister"
        
        let parm = ["uid":userAccount.uid,"avid":avid] as [String : Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (data, isSuccess, status) in
            
            if !isSuccess{
                completion(false,false,nil)
                return
            }
            if status == 401{
                completion(true,false,nil)
                return
            }
            guard let data = data as? String else{
                completion(true,false,nil)
                return
            }
            completion(true,true,data)
        }
        
    }
    
    /// 用户参加签到
    ///
    /// - Parameters:
    ///   - avid: 活动 ID
    ///   - completion: 完成回调（网络请求是否成功，签到是否成功）
    func participateActivityRegist(avid:Int,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/activity/participateregister"
        
        let parm = ["uid":userAccount.uid,"avid":avid] as [String : Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 200{
                completion(true,true)
                return
            }else if status == 400{
                completion(true,false)
                return
            }
        }
    }
    
    /// 关闭活动
    ///
    /// - Parameter completion: 完成回调（请求是否成功，关闭是否成功）
    func closeActivity(avid:Int, completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/activity/closeav"
        
        let parm = ["avid":avid]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 400{
                completion(true,false)
                return
            }
            completion(true,true)
        }
    }
    
    /// 删除活动
    ///
    /// - Parameters:
    ///   - avid: 活动 ID
    ///   - completion: 完成回调
    func deleteActivity(avid:Int,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/activity/deleteav"
        
        let parm = ["uid":userAccount.uid,"avid":avid] as [String : Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 200{
                completion(true,true)
                return
            }
            completion(true,false)
        }
    }
    
    
    /// 意见反馈
    ///
    /// - Parameters:
    ///   - bug: 问题或者建议
    ///   - contaciinfo: 联系信息
    ///   - completion: 完成回调
    func problemFeedBack(bug:String,contactinfo:String?,completion:@escaping (Bool)->()){
        
        let url = SERVERADDRESS + "/eu/common/bugreport"
        
        var parm = Parameters()
        parm["uid"] = userAccount.uid
        parm["bug"] = bug
        if contactinfo != nil && (contactinfo?.characters.count)! > 0{
            parm["contactinfo"] = contactinfo!
        }
        
        request(urlString: url, method: .post, parameters: parm) { (_, isSuccess, _) in
            if !isSuccess{
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// 根据旧密码修改密码
    ///
    /// - Parameters:
    ///   - oldpwd: 旧密码
    ///   - newpwd: 新密码
    ///   - completion: 完成回调
    func changePasswordByOldPassword(oldpwd:String,newpwd:String,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/user/changepwd"
        
        let parm = ["uid":userAccount.uid,"newpwd":newpwd,"oldpwd":oldpwd] as [String : Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (token, isSuccess, status) in
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 401{
                completion(true,false)
                return
            }
            
            guard let token = token as? String else{
                completion(true,false)
                return
            }
            completion(true,true)
            self.userAccount.accesstoken = token
            let userdict = ["uid":self.userAccount.uid,"accesstoken":token] as [String : Any]
            self.userAccount.saveToUserDefaults(dict: userdict)
        }
    }
    
    /// 更新用户信息
    ///
    /// - Parameters:
    ///   - userinfo: 用户信息
    ///   - completion: 完成回调
    func updateUserInfo(user:UserInfo,completion:@escaping (Bool)->()){
        
        let url = SERVERADDRESS + "/eu/info/changeinfo"
        
        var parm = Parameters()
        parm["uid"] = user.uid
        parm["avatar"] = user.avatar
        parm["gender"] = user.gender
        parm["nickname"] = user.nickname
        parm["professionclass"] = user.professionclass
        parm["name"] = user.name
        parm["studentid"] = user.studentid
        parm["grade"] = user.grade
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, _) in
            if !isSuccess{
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// 申请加入社团
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - completion: 完成回调
    func participateCommunity(cmid:Int,reason:String?,cmname:String,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/participatecm"
        
        var parm = ["uid":userAccount.uid,"cmid":cmid,"cmname":cmname] as [String : Any]
        if  reason != nil && reason!.characters.count > 0{
            parm["reason"] = reason
        }
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            // 已参加
            if status == 500{
                completion(true,false)
                return
            }
            completion(true,true)
        }
    }
    
    /// 收藏社团
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - completion: 完成回调
    func collectCommunity(cmid:Int,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/collectcm"
        
        let parm = ["uid":userAccount.uid,"cmid":cmid] as [String : Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 500{
                completion(true,false)
                return
            }
            completion(true,true)
        }
    }
    
    /// 取消收藏活动
    ///
    /// - Parameters:
    ///   - avid: 活动ID
    ///   - completion: 完成回调
    func discollectActivity(avid:Int,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/activity/discollectav"
        
        let parm = ["uid":userAccount.uid,"avid":avid] as [String : Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            
            if status == 500{
                completion(true,false)
                return
            }
            completion(true,true)
        }
        
    }
    
    /// 取消收藏社团
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - completion: 完成回调
    func discollectCommunity(cmid:Int,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/discollectcm"
        
        let parm = ["uid":userAccount.uid,"cmid":cmid] as [String:Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            if !isSuccess{
                completion(false,false)
                return
            }
            
            if status == 500{
                completion(true,false)
                return
            }
            completion(true,true)
        }
        
    }
    
    /// 设置默认社团（下次进入时默认进入本次最后选中的社团）
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - num: 本次的最大值 ＋ 1
    func setDefaultCommunity(cmid:Int,num:Int){
        
        let url = SERVERADDRESS + "/eu/community/setdefaultcm"
        
        let parm = ["cmid":cmid,"uid":userAccount.uid,"num":num] as [String : Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, _, _) in
            // 后台执行，失败了也没办法，无需处理任何事情
        }
    }
    
    /// 改变社团招新状态（需要实现权限判断）
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - startRecruit: 开启招新／结束招新
    ///   - completion: 完成回调
    func changeCommunityRecruitmentState(cmid:Int,startRecruit:Bool,completion:@escaping (Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/changerecruit"
        
        let recruit = startRecruit ? 1 : 0
        
        let parm = ["cmid":cmid,"recruit":recruit]
        
        tokenRequest(urlString: url, parameters: parm) { (_, isSuccess, _) in
            if !isSuccess{
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    /// 更改社团公告
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - announcement: 公告内容
    ///   - completion: 完成回调
    func changeCommunityAnnouncement(cmid:Int,announcement:String,completion:@escaping (Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/changecm"
        
        let parm = ["cmid":cmid,"cmAnnouncement":announcement] as [String:Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, _) in
            
            completion(isSuccess)
        }
    }
    
    /// 管理社团
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - uid: 被管理者 ID
    ///   - position: 职务 2表示管理员 3表示社长
    ///   - completion: 完成回调
    func manageCommunity(cmid:Int,uid:Int64,position:Int,completion:@escaping (Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/managecm"
        
        let parm = ["uid":uid,"cmid":cmid,"position":position] as [String:Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, _) in
            completion(isSuccess)
        }
    }
    
    /// 离开社团（暂时设计为被迫离开 TTTT）
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - uid: 用户 ID
    ///   - completion: 完成回调
    func leaveCommunity(cmid:Int,uid:Int64,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/leavecm"
        
        let parm = ["uid":uid,"cmid":cmid] as [String:Any]
        
        tokenRequest(urlString: url, parameters: parm) { (_, isSuccess, status) in
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 200{
                completion(true,true)
                return
            }
            completion(true,false)
            
        }
    }
    
    /// 移交社团（权限判断在本地完成）
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - newboss: 新任社长 ID
    ///   - completion: 完成回调
    func changeCommunityBoss(cmid:Int,newboss:Int64,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/delivercm"
        
        let parm = ["newboss":newboss,"oldboss":userAccount.uid,"cmid":cmid] as [String:Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 200{
                completion(true,true)
                return
            }
            completion(true,false)
        }
    }
    
    /// 修改社团信息
    ///
    /// - Parameters:
    ///   - cmid: 社团 ID
    ///   - logoname: 社团 logo 地址
    ///   - announcement: 社团公告
    ///   - detail: 社团详情
    ///   - completion: 完成回调
    func changeCommunityInfo(cmid:Int,logoname:String?,announcement:String,detail:String,completion:@escaping (Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/changecm"
        
        var parm = ["cmid":cmid,"cmAnnouncement":announcement,"cmDetail":detail] as [String:Any]
        
        if let logoname = logoname{
            parm["cmLogo"] = logoname
        }
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, _) in
            completion(isSuccess)
        }
    }
    
    /// 批量审核社团申请者
    ///
    /// - Parameters:
    ///   - uids: uid 拼接，逗号隔开
    ///   - cmid: 社团 ID
    ///   - position: 职位
    ///   - completion: 完成回调
    func verifyCommunityApplyUserList(uids:String,cmid:Int,position:Int,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/community/verifylist"
        
        let parm = ["cmid":cmid,"uids":uids,"position":position] as [String:Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 200{
                completion(true,true)
                return
            }
            completion(true,false)
            return
        }
    }
    

    /// 发送短信
    ///
    /// - Parameters:
    ///   - phonelist: 手机号序列 逗号隔开
    ///   - alert: 发送的内容
    ///   - completion: 完成回调
    func sendSms(phonelist:String,alert:String,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/push/sms"
        
        let parm = ["alert":alert,"phonelist":phonelist]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 200{
                completion(true,true)
                return
            }
            completion(true,false)
        }
    }
    

}

// MARK: - 上传接口
extension EUNetworkManager{
    
    
    enum UpLoadWhosePicture {
        case ActivityLogo
        case UserLogo
        case CommunityLogo
        case CommunityBackground
    }
    
    /// 上传图片到服务器
    ///
    /// - Parameters:
    ///   - uploadimg: 需要上传的图片
    ///   - completion: 完成回调（是否成功，图片地址）
    func uploadPicture(choice:UpLoadWhosePicture,uploadimg:UIImage,completion:@escaping (Bool,String?)->()){
        
        let activityurl = SERVERADDRESS + "/eu/cos/activity"
        let userlogourl = SERVERADDRESS + "/eu/cos/user"
        let communitylogourl = SERVERADDRESS + "/eu/cos/community/logo"
        let communitybackgroundurl = SERVERADDRESS + "/eu/cos/community/background"
        
        var url = ""
        switch choice {
        case .ActivityLogo:
            url = activityurl
            break
        case .UserLogo:
            url = userlogourl
            break
        case .CommunityLogo:
            url = communitylogourl
            break
        case .CommunityBackground:
            url = communitybackgroundurl
            break

        }
        
        //将选择的图片保存到Document目录下
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let currentTime = Int(Date().timeIntervalSince1970 * 1000)
        let filePath = "\(rootPath)/\(currentTime)"
        let imageData = UIImageJPEGRepresentation(uploadimg, 1.0)
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        //上传图片
        if (fileManager.fileExists(atPath: filePath)){

            Alamofire.upload(multipartFormData: { (multipartdata) in
                
//                multipartdata.append(URL(fileURLWithPath: filePath), withName: "file")
                multipartdata.append(URL(fileURLWithPath: filePath), withName: "file", fileName: "\(currentTime)", mimeType: "image/jpg")
                
            }, to: url, encodingCompletion: { (encodingResult) in
                
                // 接受从服务器返回的参数
//                switch encodingResult {
//                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
//                    upload.responseJSON(completionHandler: { (json) in
//                        
//                        let dict = json.result.value as? [String:Any] ?? [:]
//                        let address = dict["data"] as? String
//                        completion(true, address)
//                    })
//                    break
//                case .failure( _):
//                    completion(false,nil)
//                    break
//                    
//                }
                switch encodingResult{
                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                    upload.responseJSON(completionHandler: { (json) in
                        let dict = json.result.value as? [String:Any] ?? [:]
                        
                        let code = (dict["code"] as? Int) ?? -1
                        if code == 0{
                            completion(true,"\(currentTime)")
                            return
                        }
                        completion(false,nil)
                    })
                    return
                case .failure(_):
                    completion(false,nil)
                    return
                }
            })
            
        }
    }
    
    /// 上传认证图片
    ///
    /// - Parameters:
    ///   - name: 认证图片命名
    ///   - uploadimg: 图片
    ///   - completion: 完成回调
    func uploadVerifyPicture(name:String,uploadimg:UIImage,completion:@escaping (Bool)->()){
        
        let url = SERVERADDRESS + "/eu/cos/verify"
        //将选择的图片保存到Document目录下
        let fileManager = FileManager.default
        let rootPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let filePath = "\(rootPath)/verify.jpg"
        let imageData = UIImageJPEGRepresentation(uploadimg, 0.4)
        fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)
        
        if fileManager.fileExists(atPath: filePath){
            
            Alamofire.upload(multipartFormData: { (multipartdata) in
                multipartdata.append(URL(fileURLWithPath: filePath), withName: "file", fileName: name, mimeType: "image/jpg")
            }, to: url, encodingCompletion: { (encodingResult) in
                switch encodingResult{
                case .success(request: let upload, streamingFromDisk: _, streamFileURL: _):
                    upload.responseJSON(completionHandler: { (json) in
                        let dict = json.result.value as? [String:Any] ?? [:]
                        
                        let code = (dict["code"] as? Int) ?? -1
                        if code == 0{
                            completion(true)
                            return
                        }
                        completion(false)
                    })
                    
                    return
                case .failure(_):
                    completion(false)
                    return
                    
                }
            })
        }

        
    }
    
}

// MARK: - 推送接口
extension EUNetworkManager{
    
    
    /// 推送社团消息
    ///
    /// - Parameters:
    ///   - alias: 手机号别名串 eg.15061883391,15061883392
    ///   - alert: 通知内容
    ///   - cmid: 社团 ID
    ///   - cmname: 社团名称
    ///   - sendsms: 是否发送短信 不发送0 发送1
    ///   - completion: 完成回调
    func pushCommunityNotificationByAlias(alias:String,alert:String,cmid:Int,cmname:String,sendsms:Int,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/push/communityaliaspush"
        
        let parm = ["alias":alias,"alert":alert,"cmid":cmid,"cmname":cmname,"sendsms":sendsms] as [String:Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 200{
                completion(true,true)
                return
            }
            completion(true,false)
        }
    }
    
    /// 推送活动通知
    ///
    /// - Parameters:
    ///   - alert: 通知内容
    ///   - avid: 活动ID
    ///   - avname: 活动名称
    ///   - sendsms: 是否发送短信 不发送0 发送1
    ///   - completion: 完成回调
    func pushActivityNotificationByAlias(alert:String,avid:Int,avname:String,sendsms:Int,completion:@escaping (Bool,Bool)->()){
        
        let url = SERVERADDRESS + "/eu/push/activityPush"
        
        let parm = ["alert":alert,"avid":avid,"avname":avname,"sendsms":sendsms] as [String:Any]
        
        tokenRequest(urlString: url, method: .post, parameters: parm) { (_, isSuccess, status) in
            if !isSuccess{
                completion(false,false)
                return
            }
            if status == 200{
                completion(true,true)
                return
            }
            completion(true,false)
        }
        
    }
    
}
