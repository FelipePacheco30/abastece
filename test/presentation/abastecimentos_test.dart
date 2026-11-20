import 'package:abastece/data/armazenamento_local.dart';
import 'package:abastece/models/abastecimento.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../support/app_de_teste.dart';
import '../support/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  final anterior = abastecimento(id: 'a', quilometragem: 1000, data: DateTime(2024, 1, 1, 8));

  Future<void> tocar(WidgetTester tester, Finder alvo) async {
    await tester.ensureVisible(alvo);
    await tester.pumpAndSettle();
    await tester.tap(alvo);
    await tester.pumpAndSettle();
  }

  Future<void> preencher(
    WidgetTester tester, {
    String? preco,
    String? litros,
    String? quilometragem,
  }) async {
    final campos = {
      'Preço por litro': preco,
      'Litros': litros,
      'Quilometragem no hodômetro': quilometragem,
    };
    for (final MapEntry(key: rotulo, value: texto) in campos.entries) {
      if (texto != null) {
        await tester.enterText(find.widgetWithText(TextFormField, rotulo), texto);
      }
    }
    await tester.pumpAndSettle();
  }

  testWidgets('registra o primeiro abastecimento como referência', (tester) async {
    final garagem = await abrirApp(tester, veiculo: argo);
    expect(find.text('Nenhum abastecimento ainda'), findsOneWidget);

    await tocar(tester, find.text('Abastecer'));
    await tocar(tester, find.text('Etanol'));
    await preencher(tester, preco: '4,39', litros: '42.6', quilometragem: '21150');

    expect(find.text('R\$\u00a0187,01'), findsOneWidget);
    expect(find.text('42,6 L × R\$\u00a04,39'), findsOneWidget);

    await tocar(tester, find.text('Salvar abastecimento'));

    expect(find.text('Abastecimento registrado'), findsOneWidget);
    expect(find.text('R\$\u00a0187,01'), findsWidgets);
    expect(find.textContaining('Primeiro registro'), findsOneWidget);
    expect(garagem.historico.trechos.single.abastecimento.combustivel, Combustivel.etanol);

    final salvo = (await ArmazenamentoLocal.abrir()).lerAbastecimentos().single;
    expect(salvo.precoPorLitro, 4.39);
    expect(salvo.litros, 42.6);
    expect(salvo.quilometragem, 21150);
  });

  testWidgets('calcula km/L e R\$/km a partir do segundo abastecimento', (tester) async {
    await abrirApp(tester, veiculo: argo, abastecimentos: [anterior]);

    await tocar(tester, find.text('Abastecer'));
    expect(find.text('Anterior: 1.000 km em 01/01/2024'), findsOneWidget);
    await preencher(tester, preco: '5', litros: '40', quilometragem: '1500');
    await tocar(tester, find.text('Salvar abastecimento'));

    expect(find.textContaining('12,5 km/L · R\$\u00a00,40/km'), findsOneWidget);
  });

  testWidgets('exige preço, litros e quilometragem', (tester) async {
    await abrirApp(tester, veiculo: argo);

    await tocar(tester, find.text('Abastecer'));
    await preencher(tester, preco: '0');
    await tocar(tester, find.text('Salvar abastecimento'));

    expect(find.text('Informe o preço'), findsOneWidget);
    expect(find.text('Informe os litros'), findsOneWidget);
    expect(find.text('Informe a quilometragem'), findsOneWidget);
    expect(find.text('Novo abastecimento'), findsOneWidget);
  });

  testWidgets('a quilometragem deve ser maior que a do abastecimento anterior', (tester) async {
    await abrirApp(tester, veiculo: argo, abastecimentos: [anterior]);

    await tocar(tester, find.text('Abastecer'));
    await preencher(tester, preco: '5', litros: '40', quilometragem: '1000');
    await tocar(tester, find.text('Salvar abastecimento'));

    expect(find.text('Deve ser maior que 1.000 km, registrados em 01/01/2024'), findsOneWidget);
    expect(find.text('Novo abastecimento'), findsOneWidget);
  });

  testWidgets('edita e exclui um abastecimento recalculando os indicadores', (tester) async {
    final garagem = await abrirApp(tester, veiculo: argo, abastecimentos: historicoDeExemplo);

    await tocar(tester, find.text('Sáb, 7 nov · 18:45'));
    expect(find.text('Editar abastecimento'), findsOneWidget);
    await preencher(tester, litros: '40');
    await tocar(tester, find.text('Salvar alterações'));

    expect(find.text('Abastecimento atualizado'), findsOneWidget);
    expect(garagem.historico.trechos[7].abastecimento.litros, 40);
    expect(find.textContaining('9,3 km/L'), findsOneWidget);

    await tocar(tester, find.text('Sáb, 7 nov · 18:45'));
    await tocar(tester, find.byTooltip('Excluir abastecimento'));
    await tocar(tester, find.text('Excluir'));

    expect(find.text('Sáb, 7 nov · 18:45'), findsNothing);
    expect(find.text('Abastecimento excluído'), findsOneWidget);
    expect(garagem.historico.trechos.last.kmPorLitro, closeTo(830 / 35.1, 1e-9));
    expect((await ArmazenamentoLocal.abrir()).lerAbastecimentos(), hasLength(8));
  });
}
