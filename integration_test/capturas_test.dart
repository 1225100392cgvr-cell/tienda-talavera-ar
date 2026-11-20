import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tienda_talavera/main.dart' as app;

/// Recorre la tienda en el emulador y toma una captura de cada pantalla.
/// Se corre con: flutter drive --driver=test_driver/integration_test.dart --target=integration_test/capturas_test.dart
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  var convertida = false;

  Future<void> esperar(WidgetTester tester, Finder f) async {
    for (var i = 0; i < 60 && f.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
  }

  Future<void> foto(WidgetTester tester, String nombre) async {
    if (!convertida) {
      await binding.convertFlutterSurfaceToImage();
      convertida = true;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    await binding.takeScreenshot(nombre);
  }

  Future<void> tocar(WidgetTester tester, Finder f) async {
    await esperar(tester, f);
    await tester.ensureVisible(f.first);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(f.first);
    await tester.pump(const Duration(milliseconds: 800));
  }

  Finder enBarra(IconData icono) =>
      find.descendant(of: find.byType(NavigationBar), matching: find.byIcon(icono));

  testWidgets('recorrido de la tienda con capturas', (tester) async {
    app.main();
    await esperar(tester, find.text('Jarrón Talavera azul'));
    await foto(tester, '01_catalogo');

    await tocar(tester, find.text('Jarrón Talavera azul'));
    await esperar(tester, find.text('Agregar al carrito'));
    await foto(tester, '02_detalle_del_producto');
    await tocar(tester, find.text('Agregar al carrito'));
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 800));

    await tocar(tester, find.text('Taza Talavera'));
    await tocar(tester, find.text('Agregar al carrito'));
    await tester.pageBack();
    await tester.pump(const Duration(milliseconds: 800));

    await tocar(tester, enBarra(Icons.shopping_cart));
    await foto(tester, '03_carrito');

    await tocar(tester, enBarra(Icons.person));
    await foto(tester, '04_iniciar_sesion');
    await tocar(tester, find.text('Crear una cuenta'));
    await tester.enterText(find.widgetWithText(TextField, 'Nombre'), 'Cristopher Ramírez');
    await tester.enterText(find.widgetWithText(TextField, 'Correo'), 'cris@utng.edu.mx');
    await tester.enterText(find.widgetWithText(TextField, 'Contraseña'), 'Talavera2026');
    await tocar(tester, find.text('Registrarme'));
    await esperar(tester, find.text('Cerrar sesión'));
    await foto(tester, '05_mi_perfil');

    await tocar(tester, enBarra(Icons.shopping_cart));
    await tocar(tester, find.text('Ir a pagar'));
    await esperar(tester, find.text('Finalizar compra'));
    await foto(tester, '06_finalizar_compra');
  });
}
