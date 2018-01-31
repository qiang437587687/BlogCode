//
//  ViewController.swift
//  PushKitDemo
//
//  Created by zhangxianqiang on 2018/1/26.
//  Copyright © 2018年 zhangxianqiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var showInfotextView: UITextView!
    
    @IBAction func encallClick(_ sender: UIButton) {
        
        //endcall
        AppDelegate.shared.endCall()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(notificationMethod(noti:)), name: NSNotification.Name(rawValue: "PUSHKitNotificationForUserinfo"), object: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    func notificationMethod(noti:Notification) {
        
        print(noti.userInfo)
        self.showInfotextView.text = noti.userInfo?.description
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

