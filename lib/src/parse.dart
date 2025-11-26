part of '../entao_ini.dart';

class IniParser {
  final String _text;
  late final TextScanner _scanner = TextScanner(_text);

  IniParser(this._text);

  IniFile parse() {
    IniFile iniFile = IniFile();
    _scanner.skipWhites();
    String section = "";
    while (!_scanner.isEnd) {
      int ch = _scanner.nowChar;
      switch (ch) {
        case CharCode.LSQB:
          String sec = _parseSection();
          section = _unescapeIni(sec).unquoted;
        case CharCode.SEMI:
          _parseComment();
        // print("Comment: ${_unescapeIni(comment).unquoted}");
        default:
          MapEntry<String, String> e = _parseKeyValue();
          String key = _unescapeIni(e.key).unquoted;
          String value = _unescapeIni(e.value).unquoted;
          iniFile.put(key, value, section: section);
      }
      _scanner.skipWhites();
    }
    return iniFile;
  }

  String _parseSection() {
    _scanner.expectChar(CharCode.LSQB);
    _scanner.skipSpTab();
    List<int> buf = _scanner.moveUntilChar(CharCode.RSQB, escapeChar: CharCode.BSLASH);
    _scanner.expectChar(CharCode.RSQB);
    if (buf.isEmpty) _scanner.raise();
    return String.fromCharCodes(buf).trim();
  }

  String _parseComment() {
    _scanner.expectChar(CharCode.SEMI);
    List<int> buf = _scanner.moveUntil(CharCode.CR_LF, escapeChar: CharCode.BSLASH);
    _scanner.skipCrLf();
    return String.fromCharCodes(buf);
  }

  MapEntry<String, String> _parseKeyValue() {
    List<int> keyBuf = _scanner.moveUntilChar(CharCode.EQUAL, escapeChar: CharCode.BSLASH);
    _scanner.expectChar(CharCode.EQUAL);
    List<int> valueBuf = _scanner.moveUntil(const [CharCode.CR, CharCode.LF, CharCode.SEMI], escapeChar: CharCode.BSLASH);
    _scanner.skipCrLf();
    return MapEntry(String.fromCharCodes(keyBuf).trim(), String.fromCharCodes(valueBuf).trim());
  }
}

String _unescapeIni(String s) {
  return unescapeCharCodes(s.codeUnits, map: _ini_escapes, unicodeChars: const [CharCode.u, CharCode.U, CharCode.x, CharCode.X]);
}

const Map<int, int> _ini_escapes = {
  CharCode.BSLASH: CharCode.BSLASH,
  CharCode.SQUOTE: CharCode.SQUOTE,
  CharCode.QUOTE: CharCode.QUOTE,
  CharCode.NUL: CharCode.NUL,
  CharCode.BEL: CharCode.BEL,
  CharCode.b: CharCode.BS,
  CharCode.t: CharCode.HTAB,
  CharCode.r: CharCode.CR,
  CharCode.n: CharCode.LF,
  CharCode.SEMI: CharCode.SEMI,
  CharCode.SHARP: CharCode.SHARP,
  CharCode.EQUAL: CharCode.EQUAL,
  CharCode.COLON: CharCode.COLON,
};
