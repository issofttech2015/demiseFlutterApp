import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:async' show Future;
import "dart:convert";

Future<dynamic> getdata(dynamic args, String callingMethod,
    [String serviceConnection = '']) async {
//String url = 'http://chisel.cloudjiffy.net/contacts/short';
  final body = jsonEncode(args);
  Future<dynamic> result;
  serviceConnection = serviceConnection == ''
      ? await Util.getShared('service-url')
      : serviceConnection;
  String url = 'http://' + serviceConnection + '/' + callingMethod;
  result = http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: body,
  );
  return (result);
}

class Util {
  static Future<SharedPreferences> getSharedPreferences() async {
    return SharedPreferences.getInstance();
  }

  static void setShared(String key, dynamic value,
      [bool isList = false]) async {
    SharedPreferences shared;
    shared = await getSharedPreferences();
    if (isList) {
      shared.setStringList(key, value);
    } else {
      shared.setString(key, value);
    }
  }

  static dynamic getShared(String key, [bool isList = false]) async {
    SharedPreferences shared;
    shared = await getSharedPreferences();
    if (isList) {
      return shared.getStringList(key) ?? null; //
    } else {
      return shared.getString(key) ?? null; //
    }
  }
}
