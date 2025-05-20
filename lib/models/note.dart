import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class Note extends ParseObject implements ParseCloneable {
  Note() : super('Note');
  Note.clone() : this();

  @override
  Note clone(Map<String, dynamic> map) => Note.clone()..fromJson(map);

  String get title => get<String>('title') ?? '';
  set title(String value) => set('title', value);

  String get content => get<String>('content') ?? '';
  set content(String value) => set('content', value);

  String get category => get<String>('category') ?? '';
  set category(String value) => set('category', value);

  DateTime get createdAt => get<DateTime>('createdAt') ?? DateTime.now();

  DateTime get updatedAt => get<DateTime>('updatedAt') ?? DateTime.now();

  ParseUser? get user => get<ParseUser>('user');
  set user(ParseUser? value) => set('user', value);
}

