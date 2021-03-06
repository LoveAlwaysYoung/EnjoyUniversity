//
//  AppDelegate.swift
//  EnjoyUniversity
//
//  Created by lip on 17/2/27.
//  Copyright © 2017年 lip. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder,UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        
        /// 判断加载哪一个
        if let _ = UserDefaults.standard.string(forKey: "accesstoken"){
            window?.rootViewController = EUMainViewController()
        }else{
            window?.rootViewController = EUNavigationController(rootViewController: EULoginViewController())
        }
//        window?.rootViewController = EUserInfoInputViewController()
        window?.makeKeyAndVisible()
        
        // JPush
        let entiity = JPUSHRegisterEntity()
        entiity.types = Int(UNAuthorizationOptions.alert.rawValue |
            UNAuthorizationOptions.badge.rawValue |
            UNAuthorizationOptions.sound.rawValue)
        JPUSHService.register(forRemoteNotificationConfig: entiity, delegate: self)
        // 注册极光推送
        JPUSHService.setup(withOption: launchOptions, appKey: JPushAppKey, channel:"App Store" , apsForProduction: false)
        
        // 清除角标
        UIApplication.shared.applicationIconBadgeNumber = 0
        JPUSHService.resetBadge()
        
        // UShare
        UMSocialManager.default().umSocialAppkey = UShareAppKey
        UMSocialManager.default().setPlaform(.sina, appKey: WeiBoAppKey, appSecret: WeiBoAppSecret, redirectURL: WeiBoRedirectUrl)
        UMSocialManager.default().setPlaform(.wechatSession, appKey: WeChatAppKey, appSecret: WeChatAppSecret, redirectURL: WeiBoRedirectUrl)
        UMSocialManager.default().setPlaform(.wechatTimeLine, appKey: WeChatAppKey, appSecret: WeChatAppSecret, redirectURL: WeiBoRedirectUrl)
        UMSocialManager.default().setPlaform(.QQ, appKey: QQAppKey, appSecret: nil, redirectURL: WeiBoRedirectUrl)
        UMSocialManager.default().setPlaform(.qzone, appKey: QQAppKey, appSecret: nil, redirectURL: WeiBoRedirectUrl)
        UMSocialManager.default().removePlatformProvider(with: .wechatFavorite)

        return true
    }
    
    /// 注册APNs成功并上报DeviceToken
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        JPUSHService.registerDeviceToken(deviceToken)
        
        // 注册别名
        if let uid = UserDefaults.standard.string(forKey: "uid"){
            JPUSHService.setAlias(uid, callbackSelector: nil, object: nil)
        }
    }
    
    /// 从后台点击icon进入时清除角标
    func applicationWillEnterForeground(_ application: UIApplication) {
        UIApplication.shared.applicationIconBadgeNumber = 0
        JPUSHService.resetBadge()
    }
}


// JPush
extension AppDelegate:JPUSHRegisterDelegate{
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, didReceive response: UNNotificationResponse!, withCompletionHandler completionHandler: (() -> Void)!) {
        
        let userInfo = response.notification.request.content.userInfo
        if (response.notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
            
        }
        completionHandler()
        
    }
    
    func jpushNotificationCenter(_ center: UNUserNotificationCenter!, willPresent notification: UNNotification!, withCompletionHandler completionHandler: ((Int) -> Void)!) {
        
        
        let userInfo = notification.request.content.userInfo
        if (notification.request.trigger?.isKind(of: UNPushNotificationTrigger.self))!{
            JPUSHService.handleRemoteNotification(userInfo)
        }
        
        // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
        completionHandler(Int(UNAuthorizationOptions.alert.rawValue|UNAuthorizationOptions.sound.rawValue|UNAuthorizationOptions.badge.rawValue))
        
        
    }
    
}
