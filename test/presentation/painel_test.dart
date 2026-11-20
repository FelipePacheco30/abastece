import 'package:abastece/presentation/widgets/graficos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../support/app_de_teste.dart';
import '../support/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  testWidgets('sem abastecimentos explica o que o painel vai mostrar', (tester) async {
    await abrirApp(tester, veiculo: argo);

    expect(find.text('Seu painel aparece aqui'), findsOneWidget);
    expect(find.byType(GraficoValores), findsNothing);
  });

  testWidgets('com um abastecimento mostra o valor e avisa sobre os indicadores', (tester) async {
    await abrirApp(tester, veiculo: argo, abastecimentos: historicoDeExemplo.take(1).toList());

    expect(find.text('1 abastecimento'), findsOneWidget);
    expect(find.text('a partir do 2º registro'), findsNWidgets(2));
    expect(find.textContaining('O primeiro abastecimento é a referência'), findsOneWidget);
    expect(find.byType(GraficoValores), findsOneWidget);
    expect(find.byType(GraficoEvolucao), findsNothing);
  });

  testWidgets('mostra os indicadores gerais e os gráficos de evolução', (tester) async {
    await abrirApp(tester, veiculo: argo, abastecimentos: historicoDeExemplo);

    expect(find.text('R\$ 1.905,13'), findsOneWidget);
    expect(find.text('9 abastecimentos'), findsOneWidget);
    expect(find.text('3.370 km'), findsOneWidget);
    expect(find.text('11,1 km/L'), findsOneWidget);
    expect(find.text('R\$ 0,50/km'), findsOneWidget);
    expect(find.text('último · média R\$ 211,68'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Custo por km (R\$/km)'), 300);
    expect(find.byType(GraficoEvolucao, skipOffstage: false), findsNWidgets(2));
    expect(find.text('13,1 km/L'), findsOneWidget);
    expect(find.text('R\$ 0,48/km'), findsOneWidget);
  });
}
