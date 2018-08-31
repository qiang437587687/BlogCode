import 'package:json_annotation/json_annotation.dart';
part  'data.g.dart';

@JsonSerializable()
class Data extends Object with _$DataSerializerMixin{
  final String by;
  final int descendants;
  final int id;
  final List<int> kids;
  final int score;
  final int time;
  final String title;
  final String type;
  final String url;
  final List<Demo> demos;

  Data({this.by, this.descendants, this.id, this.kids, this.score, this.time,
    this.title, this.type, this.url,this.demos});

  factory Data.fromJson(Map<String, dynamic> json) => _$DataFromJson(json);

}

@JsonSerializable()

class Demo extends Object {
  String name;
  String age;
  Demo(this.name,this.age);

  factory Demo.fromJson(Map<String, dynamic> json) => _$DemoFromJson(json);

}

