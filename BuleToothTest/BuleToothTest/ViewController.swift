//
//  ViewController.swift
//  BuleToothTest
//
//  Created by zhangxianqiang on 2018/1/15.
//  Copyright © 2018年 BFtv. All rights reserved.
//

import UIKit
import CoreBluetooth

struct PeripheralModel {
    var name = ""
}

class ViewController: UIViewController {
    
    @IBAction func jumpToBule(_ sender: UIButton) {
        // App-Prefs:root=Bluetooth
        let url = URL.init(string: "App-Prefs:root=Bluetooth")!
        
        UIApplication.shared.open(url, options: [:]) { (f) in
            
        }
    }
    
    @IBAction func refreshButtonClick(_ sender: UIButton) {
        
        self.addInputString(str: "刷新")
        
        central.stopScan()
        deviceList.removeAll()
        peripheralSelected = nil
        tableView.reloadData()
        central.scanForPeripherals(withServices: nil, options: nil)
        
    }
    @IBAction func sendButtonClick(_ sender: UIButton) {
        //强转测试~~~
        if let _ = tempCBCharacteristic {
            writeValue(tempCBCharacteristic!)

        } else {
            
            self.addInputString(str: "tempCBCharacteristic 为空")
            
        }
        
    }
    
    @IBOutlet weak var receiveMessage: UITextView!
    
    @IBOutlet weak var inputTextField: UITextField!
    
    var deviceList = [CBPeripheral]() //搜索到的蓝牙设备
    
    var peripheralSelected : CBPeripheral? //选中的用来连接的 作用是搜索服务
    
    var tempCBCharacteristic : CBCharacteristic? //搜索到服务后的用来真正传输数据的特征。
    
    lazy var tableView:UITableView = {
        let screenSize = UIScreen.main.bounds
        let table = UITableView.init(frame: CGRect.init(x: 0, y: 300, width: screenSize.width, height: screenSize.height - 300), style: .grouped)
        table.delegate = self
        table.dataSource = self
        return table
    }()
    
    lazy var central: CBCentralManager = {
        
        return  CBCentralManager.init(delegate: self, queue: DispatchQueue.main)

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
        centralManagerDidUpdateState(central)
    }

}

//let arr = central.retrieveConnectedPeripherals(withServices: [CBUUID.init(string: "abcd1234-ab12-ab12-ab12-abcdef123456")]) // 不知如何使用

extension ViewController:CBCentralManagerDelegate,CBPeripheralDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        tempInputView.text = "初始化对象后，来到centralManagerDidUpdateState"
        
        switch central.state {
        case .unknown:
            print("CBCentralManager state:", "unknown")
            break
        case .resetting:
            print("CBCentralManager state:", "resetting")
            break
        case .unsupported:
            print("CBCentralManager state:", "unsupported")
            break
        case .unauthorized:
            print("CBCentralManager state:", "unauthorized")
            break
        case .poweredOff:
            print("CBCentralManager state:", "poweredOff")
            break
        case .poweredOn:
            print("CBCentralManager state:", "poweredOn")
            //MARK: -3.扫描周围外设（支持蓝牙）
            // 第一个参数，传外设uuid，传nil，代表扫描所有外设
            self.addInputString(str: "开始扫描设备")
            central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber.init(value: false)])
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("=============================start")
        
        if (peripheral.name != nil && peripheral.name! != "xxb") { //排除 xxb
            
            print("peripheral.name = \(peripheral.name!)")
            print("central = \(central)")
            print("peripheral = \(peripheral)")
            print("RSSI = \(RSSI)")
            print("advertisementData = \(advertisementData)")
            
            deviceList.append(peripheral)
            
            tableView.reloadData()
        }
 
        /*
        print("peripheral.name = \(peripheral.name)")
        print("central = \(central)")
        print("peripheral = \(peripheral)")
        print("RSSI = \(RSSI)")
        print("advertisementData = \(advertisementData)")
        deviceList.append(peripheral)
        
        tableView.reloadData()
        */
        print("=============================end")

    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //设备链接成功
        self.addInputString(str: "链接成功=====>\(peripheral.name ?? "~~")")
        peripheralSelected = peripheral
        peripheralSelected!.delegate = self
        peripheralSelected!.discoverServices(nil) // 开始寻找Services。传入nil是寻找所有Services
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //设备链接失败
        self.addInputString(str: "链接失败=====>\(peripheral.name ?? "~~")")
        
    }
    // cancelPeripheralConnection
    
    
    //请求周边去寻找他的服务特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            self.addInputString(str: "didDiscoverServices error ====> \(error.debugDescription) ")
            return
        }
    
        guard let serArr = peripheral.services else {
            self.addInputString(str: "Peripheral services is nil ")
            return
        }
        
      
        for ser in serArr {
            
            self.addInputString(str: "服务的UUID \(ser.uuid)")
            self.peripheralSelected!.discoverCharacteristics(nil, for: ser)
        }

        self.addInputString(str: "Peripheral 开始寻找特征 ")
        
    }
    
    //找特征的回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil { self.addInputString(str: "服务的回调error \(error.debugDescription)");return}
        
        guard let serviceCharacters = service.characteristics else {
            self.addInputString(str: "service.characteristics 为空")
            return
        }
        
        for characteristic in serviceCharacters {
            self.addInputString(str: "--------------------------characteristic")
            self.addInputString(str: "特征UUID \(characteristic.uuid)")
            self.addInputString(str: "uuidString \(characteristic.uuid.uuidString)")
            peripheralSelected!.setNotifyValue(true, for: characteristic) //接受通知
            //判断类型 <=========> 有问题的。
            /*
             CBCharacteristicPropertyBroadcast                                                = 0x01,
             CBCharacteristicPropertyRead                                                    = 0x02,
             CBCharacteristicPropertyWriteWithoutResponse                                    = 0x04,
             CBCharacteristicPropertyWrite                                                    = 0x08,
             CBCharacteristicPropertyNotify                                                    = 0x10,
             CBCharacteristicPropertyIndicate                                                = 0x20,
             CBCharacteristicPropertyAuthenticatedSignedWrites                                = 0x40,
             CBCharacteristicPropertyExtendedProperties                                        = 0x80,
             CBCharacteristicPropertyNotifyEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)    = 0x100,
             CBCharacteristicPropertyIndicateEncryptionRequired NS_ENUM_AVAILABLE(10_9, 6_0)    = 0x200
            */
            self.addInputString(str: "characteristic.properties --> \(characteristic.properties)")
            
            switch characteristic.properties {

            case CBCharacteristicProperties.write:
                self.addInputString(str: "characteristic ===> write")
                writeValue(characteristic) //写入数据
                tempCBCharacteristic = characteristic //给个全局的点，
                continue
            case CBCharacteristicProperties.writeWithoutResponse:
                self.addInputString(str: "characteristic ===> writeWithoutResponse")
                continue
            case CBCharacteristicProperties.read:
                self.addInputString(str: "characteristic ===> read")
                continue
            case CBCharacteristicProperties.notify:
                self.addInputString(str: "characteristic ===> notify")
                continue
            case CBCharacteristicProperties.indicate:
                self.addInputString(str: "characteristic ===> indicate") //获取本身的权限
                /*
                let f = UInt8(characteristic.properties.rawValue) & UInt8(CBCharacteristicProperties.write.rawValue)
                if f == CBCharacteristicProperties.write.rawValue { //判断本身有没有写的权限
                    self.addInputString(str: "characteristic ===> in indicate test write")
                    writeValue(characteristic) //写入数据
                    tempCBCharacteristic = characteristic //给个全局的点，
                }
                */
                continue
            case CBCharacteristicProperties.authenticatedSignedWrites:
                self.addInputString(str: "characteristic ===> authenticatedSignedWrites")
                continue
            case CBCharacteristicProperties.extendedProperties:
                self.addInputString(str: "characteristic ===> extendedProperties")
                continue
            case CBCharacteristicProperties.notifyEncryptionRequired:
                self.addInputString(str: "characteristic ===> notifyEncryptionRequired")
                continue
            case CBCharacteristicProperties.indicateEncryptionRequired:
                self.addInputString(str: "characteristic ===> indicateEncryptionRequired")
                
            default:
                self.addInputString(str: "characteristic ===> default")
                let f = UInt8(characteristic.properties.rawValue) & UInt8(CBCharacteristicProperties.write.rawValue)
            
                if f == CBCharacteristicProperties.write.rawValue { //判断本身有没有写的权限 这个可能是综合的 ---> 注意 16进制的转换问题~
                    self.addInputString(str: "characteristic ===> default --test-- write")
                    
                    tempCBCharacteristic = characteristic //给个全局的点，
                    self.addInputString(str: "连接成功，设置全局characteristic设置成功，可以发送数据")
                }
            }
        }
    }
    
    // 获取外设发来的数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("接到服务端发送的数据")

        if (characteristic.value != nil) {
            print("开始解析数据")
            let str = String.init(data: characteristic.value!, encoding: .utf8)
            print(str)
            receiveMessage.text = receiveMessage.text + "\n" + (str ?? "~")
        }
    }
    //接收characteristic信息
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("接收characteristic信息")
    }

    //写入的方法
    func writeValue(_ Characteristic: CBCharacteristic) {
        
        let string = inputTextField.text ?? "~测试数据"
        let data = string.data(using: .utf8)
        self.addInputString(str: "写入测试数据 ==> ")
        peripheralSelected!.writeValue(data!, for: Characteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    //写入的回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //
        if let _ = error {
            
            self.addInputString(str: "WriteValueFor characteristic error \(error.debugDescription)")
            return
        }
        self.addInputString(str: "didWriteValue success For \(characteristic) uuid = \(characteristic.uuid)")

    }
    
}


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
        
        let p = deviceList[indexPath.row]
        
        if peripheralSelected == p {
            
            self.addInputString(str: "断开设备")
            central.cancelPeripheralConnection(p)
            peripheralSelected = nil

        } else {
            
            self.addInputString(str: "链接设备")
            central.stopScan()
            central.cancelPeripheralConnection(p)
            central.connect(p, options: nil)
        }
        
    }
    
}
