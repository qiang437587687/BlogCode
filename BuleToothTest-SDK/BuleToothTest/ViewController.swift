//
//  ViewController.swift
//  BuleToothTest
//
//  Created by zhangxianqiang on 2018/1/15.
//  Copyright © 2018年 BFtv. All rights reserved.
//

import UIKit
import SystemConfiguration.CaptiveNetwork
import CoreBluetooth

struct PeripheralModel {
    var name = ""
}

class ViewController: UIViewController {
    
    @IBAction func registerFirstResponderButtonClick(_ sender: UIButton) {
        
        self.receiveMessage.resignFirstResponder()
        self.inputTextField.resignFirstResponder()
        self.tempInputView.resignFirstResponder()
        
    }
    
    @IBAction func jumpToBule(_ sender: UIButton) {
        // App-Prefs:root=Bluetooth
        let url = URL.init(string: "App-Prefs:root=Bluetooth")!
        
        UIApplication.shared.open(url, options: [:]) { (f) in
            
        }
    }
    
    @IBAction func refreshButtonClick(_ sender: UIButton) {
        self.pleaseWait()
        self.addInputString(str: "刷新")
        deviceList.removeAll()
        tableView.reloadData()
        SimpleCoreBluetooth.sharedInstance.disconnectPeripheral()
        // 再次搜索 和第一次搜索一样
        SimpleCoreBluetooth.sharedInstance.startSearchDeviceWithFilter(second: 10.0,filter: { () -> ([String]) in
            return ["cool"] //搜索小米手环
        }) { (deviceList) in
            print(deviceList) // 回传的列表
            self.deviceList.append(contentsOf: deviceList)
            self.tableView.reloadData()
            self.clearAllNotice()
        }
        
    }
    @IBAction func sendButtonClick(_ sender: UIButton) {
        //强转测试~~~
        let v = inputTextField.text ?? ""
        SimpleCoreBluetooth.sharedInstance.writeValue(strData: v) { (msg) in
            print("服务器回传的数据\(msg)")
            self.addInputString(str: "服务器回传的数据\(msg)")
            self.receiveMessage.text = (self.receiveMessage.text ?? "") + msg + "\n"
        }
        
    }
    
    @IBOutlet weak var receiveMessage: UITextView!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    var deviceList = [CBPeripheral]()
    
    lazy var tableView:UITableView = {
        let screenSize = UIScreen.main.bounds
        let height = screenSize.height * (300/667)
        let table = UITableView.init(frame: CGRect.init(x: 0, y: screenSize.height - height, width: screenSize.width/2 - 1, height: height), style: .grouped)
        table.delegate = self
        table.dataSource = self
        //table.backgroundColor = UIColor.clear
        let labelHeader = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: screenSize.width/2, height: 44))
        labelHeader.text = "  蓝牙列表："
        labelHeader.font = UIFont.systemFont(ofSize: 15)
        table.tableHeaderView = labelHeader
        return table
    }()
    
    @IBOutlet weak var tempInputView: UITextView!
    
    func addInputString(str:String) {
        
        let s = tempInputView.text + "\n" + str
        
        tempInputView.text = s
    
        print(str)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(tableView)
        let wifiMessage = getWifiInfo()
        
        self.addInputString(str: "MAC = \(wifiMessage.mac)")
        self.addInputString(str: "SSID = \(wifiMessage.ssid)")
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 在这里用 self.pleaseWait() 会有crash， 不知为何、

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        /* 最简单的扫描蓝牙
        SimpleCoreBluetooth.sharedInstance.startSearchDeviceWithFilter(filter: nil) { (backList) in
            print("backList")
        }
        */
        // 调用这个方法直接开始扫描，filter：nil表示不过滤  deviceList 是时间到了扫描到的设备列表
        SimpleCoreBluetooth.sharedInstance.startSearchDeviceWithFilter(second: 10.0,filter: { () -> ([String]) in
            return ["cool"] //
            
        }) { (deviceList) in
            
            print(deviceList) // 回传的列表
            self.deviceList = deviceList
            self.tableView.reloadData()
            self.clearAllNotice()
            self.noticeOnlyText("请点击列表中的蓝牙进行连接")

        }
        
        self.pleaseWait()
    }
    
}

extension ViewController { //获取wifi列表尝试
    
    
    func getWifiInfo() -> (ssid: String, mac: String) {
        if let cfas: NSArray = CNCopySupportedInterfaces() {
            for cfa in cfas {
                if let dict = CFBridgingRetain(
                    CNCopyCurrentNetworkInfo(cfa as! CFString)
                            ) {
                    if let ssid = dict["SSID"] as? String,
                        let bssid = dict["BSSID"] as? String {
                        return (ssid, bssid)
                    }
                }
            }
        }
        return ("未知", "未知")
    }
    
    func getWifiList() { //需要去苹果请求 使用 wifi列表
        /*
        let queue = DispatchQueue(label: "queuename", attributes: .concurrent)
        
        NEHotspotHelper.register(options: nil, queue: queue) { (cmd) in
            if cmd.commandType == NEHotspotHelperCommandType.filterScanList {
                for network in cmd.networkList! {
                    print("newwork.ssid = \(network.ssid)")
                }
            }
        }
        */
    }
    
}

//let arr = central.retrieveConnectedPeripherals(withServices: [CBUUID.init(string: "abcd1234-ab12-ab12-ab12-abcdef123456")]) // 不知如何使用




extension ViewController:UITableViewDelegate,UITableViewDataSource {
    

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return deviceList.count
    }
    
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "tableViewCell")
        if cell == nil {
            cell = UITableViewCell.init(style: .default, reuseIdentifier: "tableViewCell")
        }
        
        cell!.textLabel?.text = deviceList[indexPath.row].name  ?? "转换String错误"
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //点击链接对应的蓝牙
        // 模拟点击链接其中的外设 这里传的是0 代表deviceList中的第0个元素 serviceUUIDs characteristicUUIDs 这些可以根据需要传入，注意是数组。 f代表状态， 如果检测到 f 是error 那么连接出错。目前若没有error直接进行service查找 然后进行characteristic查找
        SimpleCoreBluetooth.sharedInstance.connectPeripheralWithIndex(peripheralDeviceIndex: indexPath.row, serviceUUIDs: nil, characteristicUUIDs: nil) { (f) in
            let _ = f
            
            switch f {
            case .success:
                self.infoNotice("连接成功，找到可以写特征")
            case .error(error: let e):
                switch e {
                case .connectCharacteristic:
                    self.infoNotice("error Characteristic")
                case .connectPeripheralError:
                    self.infoNotice("Error Peripheral")
                case .unknowError:
                    self.infoNotice("未知错误")
                }
            }
            
        }
        
    }
    
}
