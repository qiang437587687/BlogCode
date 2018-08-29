import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_douban_copy/utils/Logger.dart';

//这就是第二个页面了
class SecondScreen extends StatelessWidget {

  num left = 1;

  //这就是set get 方法，这里可以不用修改原始数据的情况下添加数据。
  num get right => left + 1;
  set right (num value) => (left = value - 1);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Second Screen"),
      ),
      body: new Center(
        child: new RaisedButton(
          onPressed: () {
            // Navigate back to first screen when tapped!
            Navigator.pop(context);
          },
          child: new Text('Go back!'),
        ),
      ),
    );
  }
}

//这个常识一下各种iOS控件

/*
* return  CupertinoPageScaffold(

        navigationBar: CupertinoNavigationBar(
          leading: RaisedButton(onPressed: _leadingButtonClick),
          middle: Text("$index"),
          trailing: RaisedButton(onPressed: _trailingButtonClick),
        ),
//
        child: new GestureDetector(onTapUp: (tap) {
          print("tap up up up");
        },
          child: new Center(child: Text("$index")),
        ) ,

      );*/



class PageIOSScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    BuildContext globalContext = context;

    CupertinoTabBar tabbar = CupertinoTabBar(items: [BottomNavigationBarItem(icon: Icon(Icons.person),title: Text("123")),
    BottomNavigationBarItem(icon: Icon(Icons.http),title: Text("456")),
    BottomNavigationBarItem(icon: Icon(Icons.movie),title: Text("789")),]);

    CupertinoTabScaffold tabScaffold = CupertinoTabScaffold(tabBar: tabbar, tabBuilder: (BuildContext context, int index) {
      assert(index >= 0 && index <= 2);
      switch (index) {
        case 0:
          return new CupertinoTabView(
            builder: (BuildContext context) {
              return CupertinoDemoTab1("$index", Colors.red, () { print("$index  leading click"); Navigator.pop(globalContext); }, () { print("$index trailing click"); });
            },
          );

        case 1:
          return new CupertinoTabView(
            builder: (BuildContext context) {
              return CupertinoDemoTab1("$index", Colors.orange, () { print("$index  leading click"); }, () { print("$index trailing click"); });
            },
          );

        case 2:
          return new CupertinoTabView(
            builder: (BuildContext context) {
              return CupertinoDemoTab1("$index", Colors.purple, () { print("$index  leading click"); }, () { print("$index trailing click"); });
            },
          );
      }

    });


    DefaultTabController dtC = DefaultTabController(
      length: 3,
      child: tabScaffold
    );

    return dtC;
  }


  _leadingButtonClick() {
    Logger.log("_leadingButtonClick", "_leadingButtonClick");
  }

  _trailingButtonClick() {
    Logger.log("_trailingButtonClick", "_trailingButtonClick");

  }


}


class CupertinoDemoTab1 extends StatelessWidget {

  CupertinoDemoTab1(this.name,this.color,this.leadingCallback,this.trailingCallback);
  final String name;
  final Color color;
  final VoidCallback leadingCallback;
  final VoidCallback trailingCallback;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build


    return CupertinoPageScaffold(

      navigationBar: CupertinoNavigationBar(
        leading: RaisedButton(onPressed: leadingCallback),
        middle: Text(name),
        trailing: RaisedButton(onPressed: trailingCallback),
      ),
//
      child: new GestureDetector(onTapUp: (tap) {
        print("tap up up up");
      },
        child: Container(color: color,child: new Center(child: Text(name)),),
      ) ,

    );
  }
}


