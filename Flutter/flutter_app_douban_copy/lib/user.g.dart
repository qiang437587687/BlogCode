// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return new User(json['name'] as String, json['email'] as String);
}

abstract class _$UserSerializerMixin {
  String get name;
  String get email;
  Map<String, dynamic> toJson() =>
      <String, dynamic>{'name': name, 'email': email};
}
