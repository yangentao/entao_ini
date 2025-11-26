import 'package:entao_ini/entao_ini.dart';
import 'package:test/test.dart';

void main() {
  String s = """
  host=google.com
  port = 8080 ; this is comment
  [account]
  ; this is another\\
   comment
  type= "admin"
  user="entao 
yang"
  [group]
  dept=dev
  desc= this is desc\\;\\n newline
  """;

  IniParser p = IniParser(s);
  IniFile ini = p.parse();
  ini.put("dept", "test", section: "group");
  String out = ini.toString();
  print(out);

  test("Ini file test", () {
    expect(ini.get("host"), "google.com");
    expect(ini.get("port"), "8080");
    expect(ini.get("user", section: "account"), "entao \nyang");
    expect(ini.get("type", section: "account"), "admin");
    expect(ini.get("dept", section: "group"), "test");
    expect(ini.get("desc", section: "group"), "this is desc;\n newline");
  });
}
