import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Recibe las capturas que toma la app en el emulador y las guarda en capturas/app/.
Future<void> main() => integrationDriver(
      onScreenshot: (String nombre, List<int> bytes, [Map<String, Object?>? args]) async {
        final f = File('capturas/app/$nombre.png');
        f.parent.createSync(recursive: true);
        f.writeAsBytesSync(bytes);
        return true;
      },
    );
