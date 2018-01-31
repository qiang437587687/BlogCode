//
//  AppDelegate.swift
//  PushKitDemo
//
//  Created by zhangxianqiang on 2018/1/26.
//  Copyright © 2018年 zhangxianqiang. All rights reserved.
//

import UIKit
import UserNotifications
import AVOSCloud
import AVOSCloudIM
import PushKit

let ConstStrting = "XIAO"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate,PKPushRegistryDelegate {

    var window: UIWindow?

    /* callkit部分 */
    var providerDelegate: ProviderDelegate!
    let callManager = CallManager()

    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func endCall() {
        
        callManager.calls.forEach { (c) in
            callManager.end(call: c)
        }
    }
    
    
    func displayIncomingCall(uuid: UUID, handle: String, hasVideo: Bool = false, completion: ((NSError?) -> Void)?) {
        
        providerDelegate.reportIncomingCall(uuid: uuid, handle: handle, hasVideo: hasVideo, completion: completion)
    
    }
    
    func makeACall(handle:String) {
        
        let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        DispatchQueue.main.asyncAfter(wallDeadline: DispatchWallTime.now() + 1.5) {
            
            print("handle = \(handle)")
            
            self.displayIncomingCall(uuid: UUID(), handle: handle, hasVideo: false) { _ in
                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
            }
        }
        
        
        
    }
    
    /********************************************/
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        providerDelegate = ProviderDelegate(callManager: callManager)
        
        registerAppNotificationSettings(launchOptions: launchOptions)
        
        AVOSCloud.setApplicationId("你的leancloud ID", clientKey: "你的leancloud key")
        
        let obj = AVObject.init(className: "testHome")
        obj.setObject("bar", forKey: "foo")
        obj.save()
        
        
        let pushRegistry = PKPushRegistry.init(queue: nil)
        pushRegistry.delegate = self
        pushRegistry.desiredPushTypes = [PKPushType.voIP]
        
        return true
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, forType type: PKPushType) {
     
        print(payload.dictionaryPayload)
        print("did konw")
        
        if  callManager.calls.count > 0 { // 这说明当前是有电话的
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PUSHKitNotificationForUserinfo"), object: nil, userInfo: ["当前有电话":"返回了"])
            
            print("[\"当前有电话\":\"返回了\"]")
            
            return
        }
        
        if payload.dictionaryPayload.count < 0 {
            print("payload.dictionaryPayload.count < 0")
            return
        }
        
        let dic = payload.dictionaryPayload as! NSDictionary
        let subV = dic.object(forKey: "aps") as! NSDictionary
        let v = subV.object(forKey: "alert")
        print(v)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "PUSHKitNotificationForUserinfo"), object: nil, userInfo: payload.dictionaryPayload)
        
        makeACall(handle: v as! String)
        
    }
    
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, forType type: PKPushType) {
        
        var token = ""
        
        for i in 0..<credentials.token.count {
            
            token = token + String(format: "%02.2hhx", arguments: [credentials.token[i]])
            
        }
        print("pushRegistry token \(token)")
        
        /*
         let ins = AVInstallation.current()
         ins.apnsTopic = "com.baofeng.xxxx"
         ins.setDeviceTokenFrom(deviceToken)
         ins.saveInBackground()
         */
        
        
        //let ins = AVInstallation.current()
        //let ins = AVInstallation.init(className: "xyhelper.voip")
    
        // 创建频道
        let temp = AVInstallation.current()
        //保存对应的installtion
        let insTempString = deleteVoipString(str: temp.objectId ?? "")
        let ins = AVInstallation.init(objectId: insTempString + ConstStrting)
        ins.apnsTopic = "com.baofeng.xxxx.voip"
        ins.setDeviceTokenFrom(credentials.token)
        ins.saveInBackground()
        print("objectID")
        print(ins.objectId ?? "")

    }

    func deleteVoipString(str:String) -> String {
        
        var temp = str
        if temp.hasSuffix(ConstStrting) {
            temp = temp.components(separatedBy: ConstStrting).first ?? ""
        }
        
        print("delete method : temp ======> \(temp)")
        return temp
    }
    
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        guard let handle = userActivity.startCallHandle else {
            print("Could not determine start call handle from user activity: \(userActivity)")
            return false
        }
        
        guard let video = userActivity.video else {
            print("Could not determine video from user activity: \(userActivity)")
            return false
        }
        print("handle = \(handle)")
        callManager.startCall(handle: handle, videoEnabled: video)
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

    
    private func registerAppNotificationSettings(launchOptions:[UIApplicationLaunchOptionsKey: Any]?) {
        
        if #available(iOS 10.0, *) {
            
            let notifiCenter = UNUserNotificationCenter.current()
            
            notifiCenter.delegate = self
            
            let types = UNAuthorizationOptions(arrayLiteral: [.alert, .badge, .sound])
            
            notifiCenter.requestAuthorization(options: types) { (flag, error) in
                
                if flag {
                    
                    print("iOS request notification success")
                    
                }else{
                    
                    print(" iOS 10 request notification fail")
                    
                }
                
            }
            
        } else { //iOS8,iOS9registration
            
            let setting = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(setting)
            
        }
        
        
        
        DispatchQueue.main.async {
            
            UIApplication.shared.registerForRemoteNotifications()
            
            let userSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
            
            UIApplication.shared.registerUserNotificationSettings(userSettings)
            
        }
        
    }

    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var token = ""
        
        for i in 0..<deviceToken.count {
            
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
            
        }
        
        
        let insTemp = AVInstallation.current()
        let ins = AVInstallation.init(objectId: deleteVoipString(str: insTemp.objectId ?? ""))
        ins.apnsTopic = "com.baofeng.xxxx"
        ins.setDeviceTokenFrom(deviceToken)
        ins.saveInBackground()
        print("objectID")
        print(ins.objectId ?? "")
        
        print("\n>>>[DeviceToken Success]:%@\n\n",token);
        
        
        //UserManager.sharedInstance.saveToken(pushToken: token)
        
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    
        print("\n>>>[DeviceToken Error]:%@\n\n",error);
        
    }
    
    //iOS10 Feature: the front desk agent notified method processing
    
    @available(iOS 10.0, *)
    
    private func userNotificationCenter(center: UNUserNotificationCenter, willPresentNotification notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void){
        
        let userInfo = notification.request.content.userInfo
        
        print("userInfo10:\(userInfo)")
        
        completionHandler([.sound,.alert])
    }
    
    
    private func userNotificationCenter(center: UNUserNotificationCenter, didReceiveNotificationResponse response: UNNotificationResponse, withCompletionHandler completionHandler: () -> Void){
        
        let userInfo = response.notification.request.content.userInfo
        
        print("userInfo10:\(userInfo)")
        
        completionHandler()
        
    }
    
    /*
     - (void)reportCallWithUUID:(NSUUID *)UUID endedAtDate:(nullable NSDate *)dateEnded reason:(CXCallEndedReason)endedReason;

     */
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]){
        
        
        print("收到远程推送消息：\(userInfo)")
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        
        let userInfo = response.notification.request.content.userInfo
        
        print("后台收到新消息Active\(userInfo)")
        
        completionHandler()
        
    }
    
    

}




