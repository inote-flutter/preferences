import 'dart:core';
// import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

///
class PrefService {
  ///
  static late SharedPreferences sharedPreferences;

  ///
  static String prefix = '';

  ///
  static bool _justCache = false;

  ///
  static late Map<String, dynamic> cache;

  ///
  static bool _hasInit = false;

  ///
  static Future<bool> init({String prefix = ''}) async {
    if (_hasInit) return false;
    PrefService.prefix = prefix;
    sharedPreferences = await SharedPreferences.getInstance();
    rebuildCache();
    _hasInit = true;
    return true;
  }

  ///
  static void setDefaultValues(Map<String, dynamic> values) {
    for (var key in values.keys) {
      if (sharedPreferences.containsKey(prefix + key)) continue;
      var val = values[key];
      if (val is bool) {
        sharedPreferences.setBool(prefix + key, val);
      } else if (val is double) {
        sharedPreferences.setDouble(prefix + key, val);
      } else if (val is int) {
        sharedPreferences.setInt(prefix + key, val);
      } else if (val is String) {
        sharedPreferences.setString(prefix + key, val);
      } else if (val is List<String>) {
        sharedPreferences.setStringList(key, val);
      }
    }
  }

  ///
  static bool? getBool(String key, {bool ignoreCache = false}) {
    checkInit();
    if (key.startsWith('!')) {
      bool? val;
      if (_justCache && !ignoreCache) {
        val = cache[prefix + key.substring(1)];
      } else {
        val = sharedPreferences.getBool('$prefix${key.substring(1)}');
      }
      if (val == null) return null;
      return !val;
    }
    if (_justCache && !ignoreCache) {
      return cache['$prefix$key'];
    } else {
      return sharedPreferences.getBool('$prefix$key');
    }
  }

  /// get bool with default value
  static bool boolDefault(String key,
      {bool ignoreCache = false, bool def = false}) {
    return getBool(key, ignoreCache: ignoreCache) ?? def;
  }

  ///
  static void setBool(String key, bool val) {
    checkInit();
    if (_justCache) {
      cache['$prefix$key'] = val;
    } else {
      sharedPreferences.setBool('$prefix$key', val);
    }
  }

  ///
  static String? getString(String key, {bool ignoreCache = false}) {
    checkInit();
    if (_justCache && !ignoreCache) {
      return cache['$prefix$key'];
    } else {
      return sharedPreferences.getString('$prefix$key');
    }
  }

  /// get string with default value
  static String stringDefault(String key,
      {bool ignoreCache = false, String def = ''}) {
    return getString(key, ignoreCache: ignoreCache) ?? def;
  }

  ///
  static void setString(String key, String val) {
    checkInit();
    if (_justCache) {
      cache['$prefix$key'] = val;
    } else {
      sharedPreferences.setString('$prefix$key', val);
    }
  }

  ///
  static int? getInt(String key, {bool ignoreCache = false}) {
    checkInit();
    if (_justCache && !ignoreCache) {
      return cache['$prefix$key'];
    } else {
      return sharedPreferences.getInt('$prefix$key');
    }
  }

  /// get int with default value
  static int intDefault(String key, {bool ignoreCache = false, int def = 0}) {
    return getInt(key, ignoreCache: ignoreCache) ?? def;
  }

  ///
  static void setInt(String key, int val) {
    checkInit();
    if (_justCache) {
      cache['$prefix$key'] = val;
    } else {
      sharedPreferences.setInt('$prefix$key', val);
    }
  }

  ///
  static double? getDouble(String key, {bool ignoreCache = false}) {
    checkInit();
    if (_justCache && !ignoreCache) {
      return cache['$prefix$key'];
    } else {
      return sharedPreferences.getDouble('$prefix$key');
    }
  }

  /// get double with default value
  static double doubleDefault(String key,
      {bool ignoreCache = false, double def = 0}) {
    return getDouble(key, ignoreCache: ignoreCache) ?? def;
  }

  ///
  static void setDouble(String key, double val) {
    checkInit();
    if (_justCache) {
      cache['$prefix$key'] = val;
    } else {
      sharedPreferences.setDouble('$prefix$key', val);
    }
  }

  ///
  static List<String>? getStringList(String key, {bool ignoreCache = false}) {
    checkInit();
    if (_justCache && !ignoreCache) {
      return cache['$prefix$key'];
    } else {
      return sharedPreferences.getStringList('$prefix$key');
    }
  }

  /// get List<String> with default value
  static List<String> stringListDefault(String key,
      {bool ignoreCache = false, List<String>? def}) {
    return getStringList(key, ignoreCache: ignoreCache) ?? def ?? [];
  }

  ///
  static void setStringList(String key, List<String> val) {
    checkInit();
    if (_justCache) {
      cache['$prefix$key'] = val;
    } else {
      sharedPreferences.setStringList('$prefix$key', val);
    }
  }

  ///
  static dynamic get(String key, {bool ignoreCache = false}) {
    checkInit();
    if (_justCache && !ignoreCache) {
      return cache['$prefix$key'];
    } else {
      return sharedPreferences.get('$prefix$key');
    }
  }

  ///
  static Set<String> getKeys() {
    checkInit();
    return sharedPreferences.getKeys();
  }

  ///
  static Map subs = {};
  static void notify(String key) {
    if (subs[key] == null) return;

    for (Function f in subs[key]) {
      f();
    }
  }

  ///
  static void onNotify(String key, Function f) {
    if (subs[key] == null) subs[key] = [];
    subs[key].add(f);
  }

  ///
  static void onNotifyRemove(String key) {
    subs[key] = null;
  }

  ///
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  ///
  static void checkInit() {
    if (!_hasInit && !_justCache) {
      throw Exception('''\n
  PrefService not initialized.
  Call await PrefService.init() before any other PrefService call.
          
  main() async {
    await PrefService.init();
    runApp(MyApp());
  }
      ''');
    }
  }

  ///
  static void rebuildCache() {
    cache = {};

    for (var key in sharedPreferences.getKeys()) {
      cache[key] = sharedPreferences.get(key);
    }
  }

  ///
  static void enableCaching() {
    _justCache = true;
  }

  ///
  static void disableCaching() {
    _justCache = false;
  }

  ///
  static void applyCache() {
    disableCaching();
    for (var key in cache.keys) {
      var val = cache[key];
      if (val is bool) {
        sharedPreferences.setBool(key, val);
      } else if (val is double) {
        sharedPreferences.setDouble(key, val);
      } else if (val is int) {
        sharedPreferences.setInt(key, val);
      } else if (val is String) {
        sharedPreferences.setString(key, val);
      } else if (val is List<String>) {
        sharedPreferences.setStringList(key, val);
      }
    }
    rebuildCache();
  }

  ///
  static void clear() {
    sharedPreferences.clear();
  }
}
