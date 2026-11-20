// Gera as capturas de tela usadas no README a partir das telas reais do app,
// com a BrasilAPI simulada pelas respostas gravadas em test/fixtures.
//
//   flutter test tool/capturas --update-goldens
import 'dart:io';

import 'package:abastece/app.dart';
import 'package:abastece/models/abastecimento.dart';
import 'package:abastece/models/veiculo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../../test/support/app_de_teste.dart';
import '../../test/support/fixtures.dart';

const _celular = Size(390, 844);

void main() {
  setUpAll(() async {
    await _carregarFontes();
    await initializeDateFormatting('pt_BR');
    EditableText.debugDeterministicCursor = true;
  });

  _cena('boas-vindas e cadastro do veículo', (tester) async {
    await _abrir(tester, veiculo: null);
    await _capturar(tester, '01_boas_vindas');

    await tester.tap(find.text('Cadastrar veículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marca'));
    await tester.pumpAndSettle();
    await _capturar(tester, '02_selecao_marca');

    await _buscarEEscolher(tester, 'fiat', 'Fiat');
    await tester.tap(find.text('Modelo'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'argo 1.3');
    await tester.pumpAndSettle();
    await _capturar(tester, '03_selecao_modelo');

    await tester.tap(find.text('ARGO DRIVE 1.3 8V Flex'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Ano'), '2022');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await _capturar(tester, '04_cadastro_veiculo');
  });

  _cena('painel', (tester) async {
    await _abrir(tester);
    await _capturar(tester, '05_painel');
    await tester.drag(find.byType(ListView), const Offset(0, -560));
    await tester.pumpAndSettle();
    await _capturar(tester, '06_painel_graficos');
  });

  _cena('abastecimentos', (tester) async {
    await _abrir(tester);
    await tester.tap(find.text('Abastecimentos'));
    await tester.pumpAndSettle();
    await _capturar(tester, '07_abastecimentos');

    await tester.tap(find.text('Abastecer'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Preço por litro'), '6,29');
    await tester.enterText(find.widgetWithText(TextFormField, 'Litros'), '36,4');
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quilometragem no hodômetro'),
      '22080',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pumpAndSettle();
    await _capturar(tester, '08_novo_abastecimento');

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quilometragem no hodômetro'),
      '21500',
    );
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.tap(find.text('Salvar abastecimento'));
    await tester.pumpAndSettle();
    await _capturar(tester, '09_validacao_quilometragem');
  });

  _cena('editar abastecimento', (tester) async {
    await _abrir(tester);
    await tester.tap(find.text('Abastecimentos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sáb, 7 nov · 18:45'));
    await tester.pumpAndSettle();
    await _capturar(tester, '10_editar_abastecimento');
  });

  _cena('veículo', (tester) async {
    await _abrir(tester);
    await tester.tap(find.text('Veículo'));
    await tester.pumpAndSettle();
    await _capturar(tester, '11_veiculo');
    await tester.tap(find.text('Excluir veículo'));
    await tester.pumpAndSettle();
    await _capturar(tester, '12_excluir_veiculo');
  });

  _cena('primeiro abastecimento', (tester) async {
    await _abrir(tester, abastecimentos: historicoDeExemplo.take(1).toList());
    await _capturar(tester, '13_painel_primeiro_abastecimento');
  });

  _cena('sem conexão', (tester) async {
    await _abrir(
      tester,
      veiculo: null,
      servico: MockClient((_) async => throw http.ClientException('sem rede')),
    );
    await tester.tap(find.text('Cadastrar veículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marca'));
    await tester.pumpAndSettle();
    await _capturar(tester, '14_sem_conexao');
  });

  _cena('tema escuro', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await _abrir(tester);
    await _capturar(tester, '15_escuro_painel');
    await tester.drag(find.byType(ListView), const Offset(0, -560));
    await tester.pumpAndSettle();
    await _capturar(tester, '16_escuro_graficos');
    await tester.tap(find.text('Abastecimentos'));
    await tester.pumpAndSettle();
    await _capturar(tester, '17_escuro_abastecimentos');
  });
}

/// Teste de captura com sombras reais; o padrão dos testes as troca por contornos.
void _cena(String nome, Future<void> Function(WidgetTester tester) roteiro) {
  testWidgets(nome, (tester) async {
    debugDisableShadows = false;
    try {
      await roteiro(tester);
    } finally {
      debugDisableShadows = true;
    }
  });
}

Future<void> _abrir(
  WidgetTester tester, {
  Veiculo? veiculo = argo,
  List<Abastecimento>? abastecimentos,
  http.Client? servico,
}) async {
  tester.view.physicalSize = _celular * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await abrirApp(
    tester,
    veiculo: veiculo,
    abastecimentos: abastecimentos ?? (veiculo == null ? const [] : historicoDeExemplo),
    servico: servico,
  );
}

Future<void> _buscarEEscolher(WidgetTester tester, String busca, String opcao) async {
  await tester.enterText(find.byType(TextField), busca);
  await tester.pumpAndSettle();
  await tester.tap(find.text(opcao));
  await tester.pumpAndSettle();
}

Future<void> _capturar(WidgetTester tester, String nome) {
  return expectLater(find.byType(App), matchesGoldenFile('../../docs/capturas/$nome.png'));
}

Future<void> _carregarFontes() async {
  final flutter =
      Platform.environment['FLUTTER_ROOT'] ??
      File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
  final icones = File('$flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');

  final inter = FontLoader('Inter');
  for (final peso in ['Regular', 'Medium', 'SemiBold']) {
    inter.addFont(rootBundle.load('assets/fonts/Inter-$peso.ttf'));
  }
  await inter.load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(Future.value(ByteData.sublistView(icones.readAsBytesSync())))).load();
}
