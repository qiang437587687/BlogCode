// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Data _$DataFromJson(Map<String, dynamic> json) {
  return new Data(
      by: json['by'] as String,
      descendants: json['descendants'] as int,
      id: json['id'] as int,
      kids: (json['kids'] as List)?.map((e) => e as int)?.toList(),
      score: json['score'] as int,
      time: json['time'] as int,
      title: json['title'] as String,
      type: json['type'] as String,
      url: json['url'] as String,
      demos: (json['demos'] as List)
          ?.map((e) =>
              e == null ? null : new Demo.fromJson(e as Map<String, dynamic>))
          ?.toList());
}

abstract class _$DataSerializerMixin {
  String get by;
  int get descendants;
  int get id;
  List<int> get kids;
  int get score;
  int get time;
  String get title;
  String get type;
  String get url;
  List<Demo> get demos;
  Map<String, dynamic> toJson() => <String, dynamic>{
        'by': by,
        'descendants': descendants,
        'id': id,
        'kids': kids,
        'score': score,
        'time': time,
        'title': title,
        'type': type,
        'url': url,
        'demos': demos
      };
}

Demo _$DemoFromJson(Map<String, dynamic> json) {
  return new Demo(json['name'] as String, json['age'] as String);
}

abstract class _$DemoSerializerMixin {
  String get name;
  String get age;
  Map<String, dynamic> toJson() => <String, dynamic>{'name': name, 'age': age};
}
