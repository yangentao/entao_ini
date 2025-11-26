part of '../entao_ini.dart';

/// https://en.wikipedia.org/wiki/INI_file
class IniFile {
  final Map<String, Map<String, String>> all = {};

  bool get isEmpty => all.isEmpty;

  bool get isNoEmpty => all.isNotEmpty;

  IniFile._({Map<String, Map<String, String>>? data}) {
    if (data != null) all.addAll(data);
  }

  factory IniFile({Map<String, Map<String, String>>? data, File? file, Encoding encoding = utf8}) {
    assert(data == null || file == null);
    if (file != null) {
      return read(file, encoding: encoding);
    } else {
      return IniFile._(data: data);
    }
  }

  static IniFile? tryRead(File file, {Encoding encoding = utf8}) {
    try {
      String s = file.readAsStringSync(encoding: encoding);
      return parse(s);
    } catch (e) {
      return null;
    }
  }

  static IniFile read(File file, {Encoding encoding = utf8}) {
    String s = file.readAsStringSync(encoding: encoding);
    return parse(s);
  }

  static IniFile parse(String text) {
    return IniParser(text).parse();
  }

  List<IniItem> get items {
    List<IniItem> ls = [];
    for (var e in all.entries) {
      for (var ee in e.value.entries) {
        var item = IniItem(key: ee.key, value: ee.value, section: e.key);
        ls.add(item);
      }
    }
    return ls;
  }

  /// default section is '', empty string.
  List<String> get sections => all.keys.toList();

  List<String> keys({String section = ""}) {
    return all[section]?.keys.toList() ?? [];
  }

  String? get(String key, {String section = ""}) {
    return all[section]?[key];
  }

  void put(String key, String value, {String section = ""}) {
    Map<String, String>? m = all[section];
    if (m != null) {
      m[key] = value;
    } else {
      all[section] = {key: value};
    }
  }

  void putItem(IniItem item) {
    put(item.key, item.value, section: item.section);
  }

  void write(File file, {Encoding encoding = utf8}) {
    String text = toText();
    file.writeAsStringSync(text, flush: true, encoding: encoding);
  }

  String toText() {
    StringBuffer buf = StringBuffer();
    Map<String, String>? m = all[""];
    if (m != null) {
      for (MapEntry<String, String> kv in m.entries) {
        buf.writeln("${kv.key}=${kv.value}");
      }
    }
    for (MapEntry<String, Map<String, String>> e in all.entries) {
      if (e.key.isEmpty) {
        continue;
      }
      buf.writeln("[${e.key}]");
      for (MapEntry<String, String> kv in e.value.entries) {
        buf.writeln("${kv.key}=${kv.value}");
      }
    }
    return buf.toString();
  }

  @override
  String toString() {
    return toText();
  }
}

class IniItem {
  String key;
  String value;
  String section;

  IniItem({required this.key, required this.value, this.section = ""});

  @override
  String toString() {
    if (section.isEmpty) return "$key=$value";
    return "[$section] $key=$value";
  }

  String toText() {
    return "$key=$value";
  }
}
