import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app_douban_copy/utils/Logger.dart';


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

    CupertinoButton lButton = CupertinoButton(child: Text("CupertinoButton"), onPressed: null);

    //这个控件直接放在leading上面会有一些位置移动，这里就需要用一个控件进行包裹，设定好位置之后再放到上面。
    GestureDetector ges = GestureDetector(onTap: leadingCallback ,child: Text("back"),);
    //用控件包裹了，这里面的Factor貌似是拉伸度，
    Align ali = Align(widthFactor: 1.0,alignment: Alignment.center,child: ges,);

    return CupertinoPageScaffold(

      navigationBar: CupertinoNavigationBar(
        //这种方法不太好啊~
        leading: Container(child: Text("123"),alignment: Alignment.center,width: 44.0,height: 44.0,),
        middle: Text(name),
        trailing: ali,
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


