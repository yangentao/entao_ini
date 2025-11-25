## Ini file read and write

## Usage
```ini
host=google.com
port = 8080 ; this is comment

[account]
; this is another\
comment
type= "admin"
user= entao \
yang

[group]
dept=dev
desc= this is desc\;\n newline
```

```dart  
  IniFile ini = IniFile.parse(s);
  println(ini);
  println();
  ini.put("dept", "test", section: "group");
  String out = ini.toString();
  println(out);

  test("Ini file test", () {
    expect("google.com", ini.get("host"));
    expect("8080", ini.get("port"));
    expect("entao \nyang", ini.get("user", section: "account"));
    expect("admin", ini.get("type", section: "account"));
    expect("test", ini.get("dept", section: "group"));
    expect("this is desc;\n newline", ini.get("desc", section: "group"));
  });
```