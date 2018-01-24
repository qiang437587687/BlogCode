//
//  ViewController.swift
//  TestNNNN
//
//  Created by zhangxianqiang on 2018/1/23.
//  Copyright © 2018年 BFtv. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func sendTestMessage(_ sender: UIButton) {
        
        SimpleCoreBluetooth.sharedInstance.writeValue(strData: "zhang") { (str) in
            print("当前接收数据是=====>\(str)")
        }
        
    }
    @IBAction func connectButton(_ sender: UIButton) {
        
        // 临时测试
    SimpleCoreBluetooth.sharedInstance.connectPeripheralWithIndex(peripheralDeviceIndex: 0, serviceUUIDs: nil, characteristicUUIDs: nil) { (f) in
            let _ = f //设备的连接状况。 如果是true 直接去寻找服务了， 找到服务开始寻找特征了， 找到特征就寻找其中可以写入的保存下来，用于写入
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    SimpleCoreBluetooth.sharedInstance.startSearchDeviceWithFilter(second: 10.0,filter: { () -> ([String]) in
            return ["cool"]
        }) { (deviceList) in
            print(deviceList)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

