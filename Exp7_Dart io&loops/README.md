# Dart I/O & Loops – Quick Reference

This project showcases core concepts of:

- **Dart I/O** (`dart:io` library)
- **Looping constructs** in Dart

---

## 📦 I/O in Dart (`dart:io`)

> ⚠️ Not supported in web apps (only CLI/server).

### Key Examples

- **Importing**:  
  `import 'dart:io';`

- **Read file as string**:
  ```dart
  var content = await File('config.txt').readAsString();
  
## Write to file:
var sink = File('output.txt').openWrite();
sink.write('Hello');
await sink.close();
## List directory files:
await for (var entity in Directory('tmp').list()) {
  print(entity.path);
}
## for loop
for (var i = 0; i < 5; i++) print(i);
## for in loop
for (var item in [1, 2, 3]) print(item);
## for each loop
list.forEach((item) => print(item));

-while / do-while, break, continue, and labeled loops also supported.


✅ Summary

Dart supports async, non-blocking file I/O.

Multiple loop types give flexible control flow.



