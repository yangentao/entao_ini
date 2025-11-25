part of '../entao_ini.dart';

IniFile parseIni(String text) {
  if (text.trim().isEmpty) return IniFile();
  Map<String, Map<String, String>> map = {};
  List<String> lines = _unescapeLines(const LineSplitter().convert(text));
  String sec = "";
  for (String line in lines) {
    final String ln = line.trim();

    if (ln.length < 3) continue; //[a], a=1
    if (ln[0] == '[' && ln[ln.length - 1] == ']') {
      sec = ln.substring(1, ln.length - 1).trim();
      continue;
    }
    int idx = ln.indexOf('=');
    if (idx <= 0) continue;
    String k = ln.substring(0, idx).trim();
    String v = ln.substring(idx + 1).trim().unquoted;
    if (k.isEmpty) continue;

    Map<String, String>? m = map[sec];
    if (m != null) {
      m[k] = v;
    } else {
      map[sec] = {k: v};
    }
  }
  return IniFile(data: map);
}

List<String> _unescapeLines(List<String> lines) {
  List<String> ls = [];
  Iterator<String> it = lines.iterator;
  while (it.moveNext()) {
    String curLine = it.current;
    if (ls.isNotEmpty && ls.last.isNotEmpty) {
      String lastLine = ls.last;
      if (lastLine.length >= 2 && lastLine.codeUnitAt(lastLine.length - 1) == _BSLASH && lastLine.codeUnitAt(lastLine.length - 2) != _BSLASH) {
        ls[ls.length - 1] = "${lastLine.substring(0, lastLine.length - 1)}\n$curLine";
        continue;
      }
    }
    ls.add(curLine);
  }
  return ls.map((e) => e.unescapeIni).toList();
}

extension _IniExt on String {
  // int? get lastChar => isEmpty ? null : codeUnitAt(length - 1);

  String get unquoted {
    if (length >= 2 && codeUnitAt(0) == _QUOTE && codeUnitAt(length - 1) == _QUOTE) {
      return substring(1, length - 1);
    }
    return this;
  }

  // TODO unicode , \xhhhh
  String get unescapeIni {
    int idx = indexOf('\\');
    if (idx < 0) {
      int semIdx = indexOf(";");
      if (semIdx < 0) {
        return this;
      } else {
        return substring(0, semIdx);
      }
    }
    StringBuffer buf = StringBuffer();
    List<int> codeList = codeUnits;
    for (int i = 0; i < codeList.length; ++i) {
      int code = codeList[i];
      if (code == _SEMI) return buf.toString();
      if (code != _BSLASH) {
        buf.writeCharCode(code);
        continue;
      }
      if (i + 1 >= codeList.length) {
        buf.writeCharCode(code);
        continue;
      }
      int c2 = codeList[i + 1];
      switch (c2) {
        case _BSLASH: // \
          buf.writeCharCode(_BSLASH);
          i += 1;
        case _QUOTE: // "
          buf.writeCharCode(_QUOTE);
          i += 1;
        case 39: // '
          buf.writeCharCode(39);
          i += 1;
        case 38: // 0
          buf.writeCharCode(0);
          i += 1;
        case 97: // \a, Bell/Alert
          buf.writeCharCode(7);
          i += 1;
        case 98: // \b
          buf.writeCharCode(8);
          i += 1;
        case 116: // \t
          buf.writeCharCode(9);
          i += 1;
        case 114: // \r
          buf.writeCharCode(13);
          i += 1;
        case 110: // \n
          buf.writeCharCode(10);
          i += 1;
        case 59: // ;
          buf.writeCharCode(59);
          i += 1;
        case 35: // #
          buf.writeCharCode(35);
          i += 1;
        case 61: // =
          buf.writeCharCode(61);
          i += 1;
        case 58: // :
          buf.writeCharCode(58);
          i += 1;
        default:
          buf.writeCharCode(code);
          buf.writeCharCode(c2);
          i += 1;
      }
    }
    return buf.toString();
  }
}

// \
const int _BSLASH = 92;
// "
const int _QUOTE = 34;
// ;
const int _SEMI = 59;
