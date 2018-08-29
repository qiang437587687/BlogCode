import 'package:flutter/material.dart';
import 'package:flutter_app_douban_copy/http/HttpManager.dart'as HttpManager;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_app_douban_copy/utils/Logger.dart';
import 'package:flutter_app_douban_copy/json/JsonDecode.dart';
//import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_app_douban_copy/another/Refresh.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";
import 'package:flutter_app_douban_copy/utils/donate.dart';
import 'package:flutter_app_douban_copy/Const.dart';
import 'package:flutter_app_douban_copy/PageiOSItem.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState(); // 有状态的控件，那么需要一个创建转台的方法
}


class _HomePageState extends State<HomePage> {
  int index = 0;

  RefreshController _refreshController;
  Scaffold _scaffold;
  BuildContext globalContext;

  String imageUrl = ""; //这里是需要后面请求后加载

  RaisedButton button;

  Image topImage = Image.asset(
    'images/lake.jpg',
    width: 0.0,
    height: 240.0,
    fit: BoxFit.cover,
  );

  _selectPosition(int index) {

    if (this.index == index) return;
    setState(() { //刷新了
      this.index = index;
      print("_actionPress _selectPosition");

    });

  }

  @override
  void initState() {
    // TODO: implement initState
    _refreshController = new RefreshController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    TextStyle style = TextStyle(
      color: Colors.red, fontWeight: FontWeight.w700,);
//    return TabController(length: null, vsync: null) //神奇啊

    _scaffold = Scaffold(
      appBar: AppBar(
        title: Text("title+$index", style: style,),
        bottom: _movieTab(),
      ),
      body: new Builder(builder: (BuildContext context) {
        return _getBody(context);
      }),
      bottomNavigationBar: _getBottomNavigationBar(),
    );

    return DefaultTabController(
      length: 3,
      child: _scaffold,
    );
  }


  _getBottomNavigationBar() {
    List<BottomNavigationBarItem> items = List<BottomNavigationBarItem>.generate(3, (index) {
        return BottomNavigationBarItem(icon: Icon(Icons.print), title: Text("text+$index"));
    });
    return BottomNavigationBar(
        onTap: _selectPosition,
        currentIndex: index,
        type: BottomNavigationBarType.fixed,
        iconSize: 24.0,
        items: items,
    );
  }

  _movieTab() { //这个是上面的appbar的bottom
    return TabBar(
      isScrollable: false,
      tabs: <Widget>[Tab(text: "tab1",icon: Icon(Icons.movie)),Tab(text: "tab2",icon: Icon(Icons.book)),Tab(text: "tab3",icon: Icon(Icons.info))],
    );
  }

  _getBody(BuildContext context) {

    globalContext = context;
    var list =  ListView(
      children: <Widget>[
        //搞一个网络加载图片。
//    new FadeInImage.memoryNetwork(
//    placeholder: kTransparentImage,
//      image:
//      'https://github.com/flutter/website/blob/master/_includes/code/layout/lakes/images/lake.jpg?raw=true',
//    ),
        NetWorkImage(imageUrll: this.imageUrl),

        titleSection,

        textSection,

        ButtonNavToPage(voidCallback: _pressButton), // 使用回调就就可以了？
        Padding(padding: const EdgeInsets.all(8.0),child: ButtonNavToPage(voidCallback: _navigationToiOSPage,titleString: "点击到iOS页面",),),
//        ChangeBackgroundButton(),

        Container(
          alignment: Alignment.center,
          child: Center(child:
          ListView(children: <Widget>[

            Text("niubi",textAlign: TextAlign.start,),
            Text("hone",textAlign: TextAlign.center,),
            Text("json",textAlign: TextAlign.right,),
            Text("gay",textAlign: TextAlign.start),
            Text("sara",textAlign: TextAlign.center,),
            Text("niubi",textAlign: TextAlign.right),
            Text("nimei"),],

            ),
          ),
          padding: const EdgeInsets.all(10.0),
          color: Colors.orange,
          width: 100.0,
          height: 200.0,
        ),
      ],
    );

//    var child = RefreshIndicator(child: list, onRefresh: _onRefresh); //下拉刷新的按钮。
    var child = RefreshLayout(child: list, onRefresh: _onRefresh,canloading: true,);
    var newRefresh = SmartRefresher(child: list,enablePullDown: true, enablePullUp: true,onRefresh: _onRefresh,onOffsetChange: _onOffsetCallback,controller: _refreshController,);

    var con = Container(padding: const EdgeInsets.all(10.0),child: newRefresh,color: Colors.white,);

    return con;

  }



  _raisedButtonClick() {
    Logger.log("测试", "_raisedButtonClick");
  }


  void _onOffsetCallback(bool isUp, double offset) {
    // if you want change some widgets state ,you should rewrite the callback
  }

  Future<Null> _onRefresh(bool flag) async {
    return Future.delayed(Duration(milliseconds: 1000), () {

        print("future delayed");

        if (flag) {

         print("future delayed flag === true");

         _refreshController.scrollTo(_refreshController.scrollController.offset+100.0); //让刷新消失。
         _refreshController.sendBack(true, RefreshStatus.idle);

         showDialog(context: context, builder: (BuildContext context) {
           return AlertDialog(title: Text("标题"),content: new SingleChildScrollView(
             child: Text("内容"),
           ),actions: <Widget>[RaisedButton(onPressed: _actionPress,child: Text("点击事件"),)],);
         });

        } else {

          _refreshController.sendBack(false, RefreshStatus.idle);
          _refreshController.scrollTo(_refreshController.scrollController.offset-100.0); //让刷新消失。
          print("future delayed flag === false");
//          showDonateDialog(
//            context: context,
//            authorDes: "21",
//            title: "ooo",
//          );
        }
    });
  }



  _actionPress() {
    //
    print("弹到拎一个位置");
    Navigator.pop(context);
    setState(() {
//        this.imageUrl = "https://img3.doubanio.com/view/photo/s_ratio_poster/public/p2529571873.jpg";
        this.imageUrl = "";
        print("_actionPress setstate");
    });
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new SecondScreen()),
    );
  }

  _navigationToiOSPage() {
    Navigator.push(
      context,
      new MaterialPageRoute(builder: (context) => new PageIOSScreen()),
    );
  }
  
  _pressButton() {
    //先搞一个 网络请求试试。

    SnackBar snackBar = SnackBar(content: Text("加载中...",textAlign: TextAlign.center,),duration: Duration(milliseconds: 5000),);
    Scaffold.of(globalContext).showSnackBar(snackBar); // 直接用类方法，然后还需要保留全局的context 。。

    String url = 'https://api.douban.com/v2/movie/in_theaters';
    HttpManager.get(url: url, onSend: (){
      print("开始请求网络了");
    },
      onSuccess: (String body) {
        print("数据是\n ======> ");
        print(body);
        //数据怎么解析成对象?????
        var s = json.decode(body);
        Logger.log("解析后的对象", s);
        List<Movie> mList =  JsonDecode.movieList(s);
        Movie m1 = mList[0];
        Logger.log("m1.title", m1.title);
        Logger.log("m1.directors", m1.directors);
        Logger.log("m1.year", m1.year);
        Logger.log("m1.images.large", m1.images.large);

        //解析成对象了，那么这里是需要一个载体进行
        String str = m1.images.large;
        if (str.length > 0) {

          Logger.log("", "out setState");

          setState(() {
            this.imageUrl = str;
            Logger.log("", "in setState url = ${this.imageUrl}");

          });}

      },
      onError: (Object e) {

        //这里需要一个tip提示。~ 一会搞，~
        Logger.log("error message ==== > ", e);
      },
    );
    Logger.log("你妹", "关注这里验证一下是不是异步加载的网络~");

    Han()._extendMethod();
  }

  /*
  Widget buttonNavToPage = Container(
    color: Colors.yellow,
    padding: const EdgeInsets.all(32.0),
    child: RaisedButton(onPressed: _pressButton, //这里不能直接这么使用？？？

      child: const Text('Launch in browser'),

    ),
  );
*/
  //写一个横向的widget
  Widget titleSection = Container(
    padding: const EdgeInsets.all(32.0),
    child: Row(
      children: <Widget>[
        Expanded(

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[ //两个控件使用的这个是上下摆放的，对齐方式是start

              Container(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text("Oeschinen Lake Campground",style: TextStyle(fontWeight: FontWeight.bold),),
              ),

              Text("Kandersteg, Switzerland",style: TextStyle(color: Colors.grey[500]),),

            ],
          ),

        ),
        Icon(
          Icons.star,
          color: Colors.red[500],
        ),
        Text('41'),
      ],
    ),
  );


  Widget textSection = Container(
    padding: const EdgeInsets.all(32.0),
    child: Text(
      '''
Lake Oeschinen lies at the foot of the Blüemlisalp in the Bernese Alps. Situated 1,578 meters above sea level, it is one of the larger Alpine Lakes. A gondola ride from Kandersteg, followed by a half-hour walk through pastures and pine forest, leads you to the lake, which warms to 20 degrees Celsius in the summer. Activities enjoyed here include rowing, and riding the summer toboggan run.
        ''',
      softWrap: true,
    ),
  );


}


//封装一个button
class ButtonNavToPage extends StatelessWidget {

  ButtonNavToPage({@required this.voidCallback, this.titleString = 'titleString'});

  final VoidCallback voidCallback;
  final String titleString;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child: RaisedButton(onPressed: voidCallback,textColor: Colors.green,child: Text(titleString)),
    );
  }
}




class ChangeBackgroundButton extends StatelessWidget {

  ChangeBackgroundButton({Key key,@required this.normalImagePath, @required BoolCallback this.bCallback, this.selectImagePath}) : super(key: key);

  final String normalImagePath;
  final String selectImagePath;
  final BoolCallback bCallback;
  final isNormal = true;

  // 这么搞才能写出来一个层叠的可以替换背景的button，有点小坑爹啊
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
//    Stack(children: <Widget>[],)
    return Stack(children: <Widget>[
          Image.asset(
            'images/lake.jpg',
            width: 200.0,
            height: 200.0,
            fit: BoxFit.cover,
          ),
          new Opacity(
            opacity: 0.5 ,//不透明度
            child: new Container(
              width: 200.0,
              height: 200.0,
              color: Colors.white,
              child: RaisedButton(onPressed: _pressButton),
            ),
          ),
          new Text("12345678"),

    ],
        alignment: AlignmentDirectional.center,
    );
  }

  _pressButton() {

    if (isNormal) {

    } else {

    }

    this.bCallback(isNormal);
    Logger.log("123", "buttonpress");

  }

}


class NetWorkImage extends StatelessWidget {

  NetWorkImage({@required this.imageUrll});

  final String imageUrll;

  Image localImage = Image.asset(
  'images/lake.jpg',
    width: 0.0,
    height: 240.0,
    fit: BoxFit.cover,
  );
   // 初始化 不能用动态变量， 方法里面是延迟处理，可以用~ 目前是这样理解。
  _netImage() {
//    return AssetImage('images/lake.jpg');
    //要给定大小啊，要不然不在视觉范围内加载不出来。~~~~ ？？？
    return Image.network(imageUrll,width: 200.0,height: 240.0,fit: BoxFit.cover);
  }

  _getLocalImage() {
    Logger.log("in _getLocalImage", "dddddd");
    return Image.asset('images/lake.jpg');
  }

  _getImage() {

    Logger.log("_netImage urllength", imageUrll.length);
    return  imageUrll.length == 0 ? _getLocalImage() : _netImage();
//    return localImage;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Center(
      child:  _getImage(),
    );
  }
}


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

class Person {
  // In the interface, but visible only in this library.
  final _name;

  String age;

  // Not in the interface, since this is a constructor.
  Person(this._name);

  // In the interface.
  String greet(String who) => 'Hello, $who. I am $_name.';
}

//实现一个类型，这里是需要实现全部的变量和方法
class Impostor implements Person { //implements 暂时当做协议处理。

  @override
  String greet(String who) {
    // TODO: implement greet
    return "123";
  }

  @override
  // TODO: implement _name
  get _name => "zhang";

  //如果是implements 那么久需要写上 get 和 set final修饰的只需要写get
  @override
  // TODO: implement age
  String get age => "19";

  @override
  void set age(String _age) {
    // TODO: implement age
    age = _age;
  }

}


//集成不需要实现全部的变量和方法，但是需要给super初始化保证初始化完整。
class Employers extends Person {
  final String age;
  final String name;
  Employers(this.age,[this.name = "DNF"]) :  super(name);
//  Employers(this.age) : age = "123" , super("killer");
}


class Han {

  _extendMethod() {
    var s = Employers("ageggggggg");
    Logger.log("name",s._name);
    Logger.log("age", s.age);
  }

}


class Personn {
  String firstName;

  Personn.fromJson(Map data) {
    print('in Person');
  }
}


class Employee extends Personn {
  // Person does not have a default constructor;
  // you must call super.fromJson(data).
  Employee.fromJson(Map data) : super.fromJson(data) {
    print('in Employee');
  }
}

//class Peer extends Personn {
//
//}


//class RefreshController {
//  ValueNotifier<int> _headerMode;
//  ValueNotifier<int> _footerMode;
//  ScrollController scrollController;
//
//  void requestRefresh(bool up) {
//    if (up) {
//      if (_headerMode.value == RefreshStatus.idle)
//        _headerMode.value = RefreshStatus.refreshing;
//    } else {
//      if (_footerMode.value == RefreshStatus.idle) {
//        _footerMode.value = RefreshStatus.refreshing;
//      }
//    }
//  }
//
//  void scrollTo(double offset) {
//    scrollController.jumpTo(offset);
//  }
//
//  void sendBack(bool up, int mode) {
//    if (up) {
//      _headerMode.value = mode;
//    } else {
//      _footerMode.value = mode;
//    }
//  }
//
//  int get headerMode => _headerMode.value;
//
//  int get footerMode => _footerMode.value;
//
//  isRefresh(bool up) {
//    if (up) {
//      return _headerMode.value == RefreshStatus.refreshing;
//    } else {
//      return _footerMode.value == RefreshStatus.refreshing;
//    }
//  }
//}