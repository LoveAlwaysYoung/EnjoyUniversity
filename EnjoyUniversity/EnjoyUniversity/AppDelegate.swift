//
//  AppDelegate.swift
//  EnjoyUniversity
//
//  Created by lip on 17/2/27.
//  Copyright © 2017年 lip. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow()
        
        /// 判断加载哪一个
//        if let _ = UserDefaults.standard.string(forKey: "accesstoken"){
//            window?.rootViewController = EUMainViewController()
//        }else{
//            window?.rootViewController = EULoginViewController()
//        }
//
        window?.rootViewController = EUserInfoInputViewController()
//        window?.rootViewController = EUMainViewController()
        window?.makeKeyAndVisible()
        
        return true
    }


}

