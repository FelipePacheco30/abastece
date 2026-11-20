import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../support/app_de_teste.dart';
import '../support/fixtures.dart';

/// Telas em um celular pequeno com a fonte do sistema ampliada: qualquer
/// estouro de layout faz o teste falhar.
void main() {
  Future<void> rolarAte(WidgetTester tester, Finder alvo) =>
      tester.scrollUntilVisible(alvo, 200, scrollable: find.byType(Scrollable).first);

  setUpAll(() => initializeDateFormatting('pt_BR'));

  for (final escala in [1.5, 2.0]) {
    testWidgets('telas sem estouro com fonte em ${(escala * 100).round()}%', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = escala;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await abrirApp(tester, veiculo: argo, abastecimentos: historicoDeExemplo);
      await rolarAte(tester, find.text('Custo por km (R\$/km)'));
      await tester.drag(find.byType(ListView), const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(find.text('Média do período'), findsWidgets);

      await tester.tap(find.text('Abastecer'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextFormField, 'Preço por litro'), '6,299');
      await tester.enterText(find.widgetWithText(TextFormField, 'Litros'), '155,5');
      await tester.pumpAndSettle();
      await rolarAte(tester, find.text('Valor total'));
      expect(find.text('R\$ 979,49'), findsOneWidget);

      await tester.tap(find.byTooltip('Voltar'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.receipt_long_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.directions_car_outlined));
      await tester.pumpAndSettle();
      await rolarAte(tester, find.text('Excluir veículo'));
      expect(find.text('Excluir veículo'), findsOneWidget);
    });
  }
}
