# BlogCode

这里是一个蓝牙连接的库，封装成一个类方便使用。建议使用SDK版本，详细设置情况demo，简单的使用方法如下：
```swift

//最简单的扫描
SimpleCoreBluetooth.sharedInstance.startSearchDeviceWithFilter(filter: nil) { (backList) in
    print(backList)
}


//选中其中一个蓝牙进行连接
SimpleCoreBluetooth.sharedInstance.connectPeripheralWithIndex(peripheralDeviceIndex: indexPath.row, serviceUUIDs: nil, characteristicUUIDs: nil) { (f) in
    // f 是代表的连接成功和失败
}


// 发送数据后服务器回传的数据\(msg)
SimpleCoreBluetooth.sharedInstance.writeValue(strData: v) { (msg) in
    print(msg) 
}

```


