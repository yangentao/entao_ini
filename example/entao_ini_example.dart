import 'package:entao_ini/entao_ini.dart';

void main() {
  StringBuffer buf = StringBuffer();
  buf.write("a");
  buf.writeCharCode(BSLASH);
  buf.writeCharCode(BSLASH);
  buf.write("b");
  buf.writeCharCode(BSLASH);
  buf.write("#");
  buf.write("c");
  buf.writeCharCode(BSLASH);
  buf.write("n");
  buf.write("d");
  print(buf.toString());
  print(buf.toString().unescapeIni);
}
