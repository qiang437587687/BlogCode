//
//  SimpleCoreBluetooth.swift
//  BuleToothTest
//
//  Created by zhangxianqiang on 2018/1/23.
//  Copyright © 2018年 BFtv. All rights reserved.
//

import Foundation
import CoreBluetooth
import NetworkExtension
import SystemConfiguration.CaptiveNetwork
import ObjectiveC.NSObjCRuntime

enum ConnectError {
    
    case connectPeripheralError
    case connectCharacteristic
    case unknowError
}

enum BlueConnectStatusENUM {
    
    case success
    case error(error:ConnectError) //
}

typealias BlueToothFilterClosure = () -> ([String]) //名称过滤
typealias BlueToothBackDeviceClosure = ([CBPeripheral]) -> ()
typealias BlueToothConnectPeripheralStatusClosure = (BlueConnectStatusENUM) -> ()
typealias BlueToothMessageBackClosure = (String) -> ()


class SimpleCoreBluetooth:NSObject {
    
    static let sharedInstance = SimpleCoreBluetooth() //写成一个单例。
    private override init() {}
    
    fileprivate var peripheralSelected : CBPeripheral? //选中的用来连接的 作用是搜索服务
    
    fileprivate var tempCBCharacteristic : CBCharacteristic? //搜索到服务后的用来真正传输数据的特征。
    
    fileprivate var deviceList = [CBPeripheral]() //搜索到的蓝牙设备
    
    fileprivate lazy var central: CBCentralManager = {
        return  CBCentralManager.init(delegate: self, queue: DispatchQueue.main)
    }()
    
    fileprivate var backClosure:BlueToothBackDeviceClosure!
    fileprivate var peripheralStatusClosure:BlueToothConnectPeripheralStatusClosure?
    fileprivate var backMessageClosure:BlueToothMessageBackClosure?
    fileprivate var serviceUUIDs_Store: [CBUUID]?
    fileprivate var characteristicUUIDs_Store : [CBUUID]?
    fileprivate var startSearchDeviceUUID_Store : [CBUUID]?
    fileprivate var filterMessage : Array<String>?
    
    fileprivate var scanDeviceFlag:Bool = false
    fileprivate var scancharacteristicFlag:Bool = false
    fileprivate var poweredOnFlag:Bool = false
    
    fileprivate var searchMethodTimeout : Double = 60.0
    
    /// second ：等待的扫描时间 默认60秒， blk 筛选的闭包，传回来一个name过滤数组
    func startSearchDeviceWithFilter(second: Double = 60.0,Services:[CBUUID]? = nil,filter:BlueToothFilterClosure?, backDevice:@escaping BlueToothBackDeviceClosure) { //找到一个可以逃逸的例子啦。
        filterMessage =  filter?() //获取用户的过滤信息 -> 目前传回来的是一个数组，里面包含用户需要的信息 可以是nil
        startSearchDeviceUUID_Store = Services
        
        searchMethodTimeout = second
        
        backClosure = backDevice
        
        scanDeviceFlag = false
        
        scancharacteristicFlag = false
        
        if let _ = peripheralSelected { print("请先断开外设连接再重新开始搜索");return}
        
        if poweredOnFlag { //已经打开蓝牙有了搜索的记录了，直接搜索。否则需要等待状态
            dickDockMethodScanForPeripherals(second: searchMethodTimeout)
        } else {
            let _ = central //启动central回调到centralManagerDidUpdateState
        }
        
    }
    
    fileprivate func dickDockMethodScanForPeripherals(second: Double = 60.0) {
    
        central.scanForPeripherals(withServices: startSearchDeviceUUID_Store, options: [CBCentralManagerScanOptionAllowDuplicatesKey: NSNumber.init(value: false)])
        
        
        DispatchQueue.global().asyncAfter(deadline: .now() + second) {
    // 到时间了结束啦。
            print("扫描蓝牙外设到时间，结束扫描，回传蓝牙外设列表")
            self.scanDeviceFlag = true
            DispatchQueue.main.async(execute: {
                self.endSearch()
            })
        }
    }
    
    func endSearch() {
        
        central.stopScan() //停止扫描
        backClosure(deviceList)//回传数据啦。
        
    }
    
    //从连接外设到搜索服务 默认给 60秒的时间， 在此期间如果完成
    func connectPeripheralWithIndex(peripheralDeviceIndex:Int,second: Double = 60.0,serviceUUIDs: [CBUUID]?,characteristicUUIDs: [CBUUID]?,conectStatus:@escaping BlueToothConnectPeripheralStatusClosure) {
        
        if scanDeviceFlag == false { print("正在扫描设备别着急连接啊~");return}
        
        peripheralStatusClosure = conectStatus //保存闭包
        serviceUUIDs_Store = serviceUUIDs
        characteristicUUIDs_Store = characteristicUUIDs
        
        if peripheralDeviceIndex + 1 > deviceList.count { print("传入的index超越数组的index啦~");return}
        peripheralSelected = deviceList[peripheralDeviceIndex]
        central.connect(peripheralSelected!, options: nil) //连接外设
        
        let item = DispatchWorkItem.init {
            // 到时间了结束啦。
            self.scancharacteristicFlag = true
            print("连接外设 扫描服务 寻找特征 一共花费\(second)秒 连接结束")
        } //这货可以取消
        
        DispatchQueue.global().asyncAfter(deadline: .now() + second, execute: item)
        
    }
    
    func disconnectPeripheral() {
        
        if let p = peripheralSelected {
            central.cancelPeripheralConnection(p)
            peripheralSelected = nil
            tempCBCharacteristic = nil
            print("断开链接peripheralSelected 清理 peripheralSelected tempCBCharacteristic")
        } else {
            print("还没有保存连接，无法执行断开")
        }
    }
    
    func statusConnectCheck() -> BlueConnectStatusENUM {
        print("如果给定的时间不够长 查询此状态可能有误！")
        /*
         fileprivate var peripheralSelected : CBPeripheral? //选中的用来连接的 作用是搜索服务
         fileprivate var tempCBCharacteristic : CBCharacteristic? //搜索到服务后的用来真正传输数据的特征。
         */
        if scanDeviceFlag == false { print("正在扫描设备"); return .error(error: .connectPeripheralError)}
        
        if scancharacteristicFlag == false { print("正在扫描特征信息");return .error(error: .connectCharacteristic) }
        
        if let _ = tempCBCharacteristic  { return .success }
        
        if let _ = peripheralSelected { return .error(error: .connectCharacteristic) }
        
        return .error(error: .unknowError)
    }
    
    func writeValue(strData:String, msgClosure:BlueToothMessageBackClosure?) { // 写入数据的方法。目前仅仅是发送字符串。
        backMessageClosure = msgClosure
        
        guard let p = peripheralSelected else{
            print("检测peripheralSelected为空")
            return
        }
        
        // tempCBCharacteristic
        guard let c = tempCBCharacteristic else{
            print("检测可写tempCBCharacteristic为空")
            return
        }
        
        let data = strData.data(using: .utf8)
        p.writeValue(data!, for: c, type: CBCharacteristicWriteType.withResponse)
        
    }
    
}

extension SimpleCoreBluetooth:CBCentralManagerDelegate,CBPeripheralDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        print("初始化对象后，来到centralManagerDidUpdateState")
        
        switch central.state {
        case .unknown:
            print("CBCentralManager state:", "unknown 重新开启蓝牙试试")
            break
        case .resetting:
            print("CBCentralManager state:", "resetting 重新开启蓝牙试试")
            break
        case .unsupported:
            print("CBCentralManager state:", "unsupported ")
            break
        case .unauthorized:
            print("CBCentralManager state:", "unauthorized ")
            break
        case .poweredOff:
            print("CBCentralManager state:", "poweredOff 重新开启蓝牙试试")
            break
        case .poweredOn:
            print("CBCentralManager state:", "poweredOn")
            //MARK: -3.扫描周围外设（支持蓝牙）
            // 第一个参数，传外设uuid，传nil，代表扫描所有外设
            print("开始扫描设备")
            poweredOnFlag = true
            dickDockMethodScanForPeripherals(second: searchMethodTimeout) //这里可以写到 poweredOnFlag didset 不过后期看起来有点费劲。现在直接写这里好了。
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        print("=============================start")
        
        guard let name = peripheral.name else { return } //不存在直接返回不再做下一步判断。
        
        print("peripheral.name = \(peripheral.name!)")
        print("central = \(central)")
        print("peripheral = \(peripheral)")
        print("RSSI = \(RSSI)")
        print("advertisementData = \(advertisementData)")
        
        if let message = filterMessage, message.count > 0 { // 过滤的数组存在，并且有真货
            
            message.forEach({ (s) in
                name.contains(s) ? deviceList.append(peripheral) : nil //找到 添加
            })
            
        } else {
            
            deviceList.append(peripheral) // 没有过滤条件 名字不为空就添加。
            
        }
        
        print("=============================end")
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //设备链接成功
        print("链接成功=====>\(peripheral.name ?? "~~") 开始寻找Services")
        peripheralSelected = peripheral
        peripheralSelected!.delegate = self
        peripheralSelected!.discoverServices(serviceUUIDs_Store) // 开始寻找Services。传入nil是寻找所有Services
//        peripheralStatusClosure?(true) //通知用户连接状态
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        //设备链接失败
        print("链接失败=====>\(peripheral.name ?? "~~")")
        peripheralStatusClosure?(.error(error: .connectPeripheralError))
    }
    
    // cancelPeripheralConnection
    
    
    //请求周边去寻找他的服务特征
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if error != nil {
            print("didDiscoverServices error ====> \(error.debugDescription) ")
            return
        }
        
        guard let serArr = peripheral.services else {
            print("Peripheral services is nil ")
            return
        }
        
        
        for ser in serArr {
            
            print("服务的UUID \(ser.uuid)")
            self.peripheralSelected!.discoverCharacteristics(characteristicUUIDs_Store, for: ser)
        }
        
        print("Peripheral 开始寻找特征 ")
        
    }
    
    //找特征的回调
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if error != nil { print("服务的回调error \(error.debugDescription)");return}
        
        guard let serviceCharacters = service.characteristics else {
            print("service.characteristics 为空")
            return
        }
        
        for characteristic in serviceCharacters {
            print("--------------------------characteristic")
            print("特征UUID \(characteristic.uuid)")
            print("uuidString \(characteristic.uuid.uuidString)")
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
            print("characteristic.properties --> \(characteristic.properties)")
            
            switch characteristic.properties {
                
            case CBCharacteristicProperties.write:
                print("characteristic ===> write")
                tempCBCharacteristic = characteristic //给个全局的characteristic，
                peripheralStatusClosure?(.success)
                continue
            case CBCharacteristicProperties.writeWithoutResponse:
                print("characteristic ===> writeWithoutResponse")
                continue
            case CBCharacteristicProperties.read:
                print("characteristic ===> read")
                continue
            case CBCharacteristicProperties.notify:
                print("characteristic ===> notify")
                continue
            case CBCharacteristicProperties.indicate:
                print("characteristic ===> indicate") //获取本身的权限
                /*
                 let f = UInt8(characteristic.properties.rawValue) & UInt8(CBCharacteristicProperties.write.rawValue)
                 if f == CBCharacteristicProperties.write.rawValue { //判断本身有没有写的权限
                 print("characteristic ===> in indicate test write")
                 writeValue(characteristic) //写入数据
                 tempCBCharacteristic = characteristic //给个全局的characteristic，
                 }
                 */
                continue
            case CBCharacteristicProperties.authenticatedSignedWrites:
                print("characteristic ===> authenticatedSignedWrites")
                continue
            case CBCharacteristicProperties.extendedProperties:
                print("characteristic ===> extendedProperties")
                continue
            case CBCharacteristicProperties.notifyEncryptionRequired:
                print("characteristic ===> notifyEncryptionRequired")
                continue
            case CBCharacteristicProperties.indicateEncryptionRequired:
                print("characteristic ===> indicateEncryptionRequired")
                
            default:
                print("characteristic ===> default")
                let f = UInt8(characteristic.properties.rawValue) & UInt8(CBCharacteristicProperties.write.rawValue)
                
                if f == CBCharacteristicProperties.write.rawValue { //判断本身有没有写的权限 这个可能是综合的 ---> 注意 16进制的转换问题~
                    print("characteristic ===> default --test-- write")
                    
                    tempCBCharacteristic = characteristic //给个全局的characteristic，
                    print("连接成功，设置全局characteristic设置成功，可以发送数据")
                    peripheralStatusClosure?(.success)
                }
            }
        }
    }
    
    
    // 获取外设发来的数据
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        print("接到服务端发送的数据")
        
        if (characteristic.value != nil) {
            print("开始解析数据")
            if let v = characteristic.value {
                let str = String.init(data: v, encoding: .utf8)
                print("接收端str = \(str)")
                backMessageClosure?(str ?? "~~??数据") //回传数据给使用者
                
            } else {
                print("characteristic.value 为nil")
            }
        }
    }
    
    //接收characteristic信息
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        print("接收characteristic信息")
    }
    
    
    //写入的回调
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //
        if let _ = error {
            
            print("WriteValueFor characteristic error \(error.debugDescription)")
            return
        }
        print("didWriteValue success For \(characteristic) uuid = \(characteristic.uuid)")
        
    }
    
}



