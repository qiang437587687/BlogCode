//
//  ViewController.swift
//  TestNNNN
//
//  Created by zhangxianqiang on 2018/1/23.
//  Copyright © 2018年 BFtv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBAction func disconnectButtonClick(_ sender: UIButton) {
        SimpleCoreBluetooth.sharedInstance.disconnectPeripheral()
    }
    
    @IBAction func reconnectButtonClick(_ sender: UIButton) { // 模拟 再次链接
        
        SimpleCoreBluetooth.sharedInstance.startSearchDeviceWithFilter(second: 10.0,filter: { () -> ([String]) in
            return ["MI"] //搜索小米手环
            
        }) { (deviceList) in
            
            print(deviceList) // 回传的列表
        }
    
    }
    
    @IBAction func sendTestMessage(_ sender: UIButton) { //模拟 发送数据
        
        SimpleCoreBluetooth.sharedInstance.writeValue(strData: "zhang") { (str) in
            print("当前接收数据是=====>\(str)")
        }
        
    }
    
    
    
    @IBAction func connectButton(_ sender: UIButton) {
        
        // 模拟点击链接其中的外设 这里传的是0 代表deviceList中的第0个元素 serviceUUIDs characteristicUUIDs 这些可以根据需要传入，注意是数组。 f代表状态， 如果检测到 f 是error 那么连接出错。目前若没有error直接进行service查找 然后进行characteristic查找
    SimpleCoreBluetooth.sharedInstance.connectPeripheralWithIndex(peripheralDeviceIndex: 0, serviceUUIDs: nil, characteristicUUIDs: nil) { (f) in
            let _ = f
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    // 调用这个方法直接开始扫描，filter：nil表示不过滤  deviceList 是时间到了扫描到的设备列表
    SimpleCoreBluetooth.sharedInstance.startSearchDeviceWithFilter(second: 10.0,filter: { () -> ([String]) in
            return ["MI"] //搜索小米手环
        
        }) { (deviceList) in
        
            print(deviceList) // 回传的列表
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

