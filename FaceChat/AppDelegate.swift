//
//  AppDelegate.swift
//  FaceChat
//
//  Created by yantommy on 2019/1/18.
//  Copyright © 2019 yantommy. All rights reserved.
//

import UIKit
import AVOSCloudIM

import Photos

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window?.layer.cornerRadius = kBTNWindowCornerRadii
        window?.layer.masksToBounds = true
        
        AVOSCloud.setApplicationId("Bt74kUq7AtyNI3irHPeuyyrn-gzGzoHsz", clientKey: "9XGTTcj7Dm7ecqK4ul268VHU")
        AVOSCloud.setAllLogsEnabled(false)
        
        
        ZYNetworkAccessibity.start()
        NotificationCenter.default.addObserver(self, selector: #selector(self.networkChanged(_:)), name: NSNotification.Name.ZYNetworkAccessibityChanged, object: nil)
        
        if AVUser.current() != nil {
            BTNUserManager.shard.currentUser = AVUser.current()!
            BTNUserManager.shard.isInfoCompleted { (success) in
                if !success {
                    let destin = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "kBTNSettingUserInfoVC")
                    let nav = UINavigationController(rootViewController: destin)
                    self.window?.rootViewController = nav
                } else {
                    let destin = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "mainVC")
                    self.window?.rootViewController = destin
                }
            }

        } else {
            let destin = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginVC")
            self.window?.rootViewController = destin
        }
        
       
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}



extension AppDelegate {
    
    @objc func networkChanged(_ sender: Notification) {
        let state = ZYNetworkAccessibity.currentState()
        
        switch state {
        case .checking:
            print("checking")
        case .unknown:
            print("unknow")
        case .restricted:
            print("网络被关闭")
            ZYNetworkAccessibity.setAlertEnable(true)
        default:
            print("以获取网络权限")
        }
        
    }
    
    
    func initPrivice(){
        
        let video = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        //用户已经授权应用访问照片数据
        if(video == .authorized) {
            // authorized用户已经明确否认了这一照片数据的应用程序访问
        } else if(video == .denied){
            // denied// 此应用程序没有被授权访问的照片数据。可能是家长控制权限
        } else if(video == .restricted){
            // restricted// 用户尚未做出选择这个应用程序的问候
        } else if(video == .notDetermined){
            // not determined
            
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (success) in
                
                if success {
                    
                    print("获取了视频权限")
                }else{
                    
                    print("没有视频权限")
                }
            })
            
        }
        
        let audio = AVCaptureDevice.authorizationStatus(for: AVMediaType.audio)
        //用户已经授权应用访问照片数据
        if(audio == .authorized) {
            // authorized用户已经明确否认了这一照片数据的应用程序访问
        } else if(audio == .denied){
            // denied// 此应用程序没有被授权访问的照片数据。可能是家长控制权限
        } else if(audio == .restricted){
            // restricted// 用户尚未做出选择这个应用程序的问候
        } else if(audio == .notDetermined){
            // not determined
            
            AVCaptureDevice.requestAccess(for: AVMediaType.audio, completionHandler: { (success) in
                
                if success {
                    
                    print("获取了音频权限")
                }else{
                    
                    print("没有音频权限")
                }
            })
            
        }
        
        
        //iOS 9+
        let photo = PHPhotoLibrary.authorizationStatus()
        //        //ios 8
        //        let photo = ALAssetsLibrary.authorizationStatus()
        //用户已经授权应用访问照片数据
        if(photo == .authorized) {
            // authorized用户已经明确否认了这一照片数据的应用程序访问
        } else if(photo == .denied){
            // denied// 此应用程序没有被授权访问的照片数据。可能是家长控制权限
        } else if(photo == .restricted){
            // restricted// 用户尚未做出选择这个应用程序的问候
        } else if(photo == .notDetermined){
            // not determined
            
        }
        
        
        
    }
}


