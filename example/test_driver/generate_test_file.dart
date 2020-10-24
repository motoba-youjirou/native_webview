import 'dart:io';

Future<void> main() async {
  final dir = Directory('test_driver/tests');
  final files = <File>[];
  await for (final file in dir.list(recursive: true)) {
    files.add(file);
  }

  final imports = files.map((file) {
    final basename = file.path?.split("/")?.last;
    final name = basename?.replaceAll(".dart", "");
    return """
import "tests/${basename}" as ${name};
""";
  }).join("");

  final tests = files.map((file) {
    final name = file.path?.split("/")?.last?.replaceAll(".dart", "");
    return """
  group("${name}", ${name}.main);
""";
  }).join("");

  final body = """
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

${imports}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
${tests}
}
""";

  final testFile = File("test_driver/native_webview_e2e.dart");
  await testFile.writeAsString(body);
}
