import 'package:abastece/data/armazenamento_local.dart';
import 'package:abastece/presentation/screens/tela_boas_vindas.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:intl/date_symbol_data_local.dart';

import '../support/app_de_teste.dart';
import '../support/fixtures.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  Future<void> escolher(WidgetTester tester, String campo, String busca, String opcao) async {
    await tester.tap(find.text(campo));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), busca);
    await tester.pumpAndSettle();
    await tester.tap(find.text(opcao));
    await tester.pumpAndSettle();
  }

  testWidgets('cadastra o veículo com marca e modelo da FIPE', (tester) async {
    final garagem = await abrirApp(tester);
    expect(find.byType(TelaBoasVindas), findsOneWidget);

    await tester.tap(find.text('Cadastrar veículo'));
    await tester.pumpAndSettle();
    await escolher(tester, 'Marca', 'fiat', 'Fiat');
    await escolher(tester, 'Modelo', 'argo drive 1.3', 'ARGO DRIVE 1.3 8V Flex');
    await tester.enterText(find.widgetWithText(TextFormField, 'Ano'), '2022');
    await tester.tap(find.text('Salvar veículo'));
    await tester.pumpAndSettle();

    expect(find.text('Seu painel aparece aqui'), findsOneWidget);
    await tester.tap(find.text('Veículo'));
    await tester.pumpAndSettle();
    expect(find.text('ARGO DRIVE 1.3 8V Flex'), findsOneWidget);
    expect(find.text('1,3 L'), findsOneWidget);
    expect(garagem.veiculo?.ano, 2022);

    final reaberto = await ArmazenamentoLocal.abrir();
    expect(reaberto.lerVeiculo()?.marca, 'Fiat');
    expect(reaberto.lerVeiculo()?.cilindrada, 1.3);
  });

  testWidgets('exige marca, modelo, ano e cilindrada válidos', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Cadastrar veículo'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha a marca primeiro'), findsOneWidget);
    await tester.tap(find.text('Salvar veículo'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha a marca'), findsOneWidget);
    expect(find.text('Informe o ano'), findsOneWidget);
    expect(find.text('Informe a cilindrada'), findsOneWidget);

    await escolher(tester, 'Marca', 'fiat', 'Fiat');
    await tester.enterText(find.widgetWithText(TextFormField, 'Ano'), '1900');
    await tester.enterText(find.widgetWithText(TextFormField, 'Cilindrada'), '0,1');
    await tester.tap(find.text('Salvar veículo'));
    await tester.pumpAndSettle();

    expect(find.text('Escolha o modelo'), findsOneWidget);
    expect(find.textContaining('Informe um ano entre 1950'), findsOneWidget);
    expect(find.text('Use um valor entre 0,5 e 10,0'), findsOneWidget);
    expect(find.text('Cadastrar veículo'), findsOneWidget);
  });

  testWidgets('trocar a marca limpa o modelo escolhido', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Cadastrar veículo'));
    await tester.pumpAndSettle();
    await escolher(tester, 'Marca', 'fiat', 'Fiat');
    await escolher(tester, 'Modelo', 'argo drive 1.3', 'ARGO DRIVE 1.3 8V Flex');

    await escolher(tester, 'Marca', 'ford', 'Ford');

    expect(find.text('ARGO DRIVE 1.3 8V Flex'), findsNothing);
  });

  testWidgets('mostra a falha da BrasilAPI e permite tentar de novo', (tester) async {
    var online = false;
    await abrirApp(
      tester,
      servico: MockClient((requisicao) async {
        if (!online) throw http.ClientException('sem rede');
        return respostaBrasilApi('marcas_carros.json');
      }),
    );
    await tester.tap(find.text('Cadastrar veículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marca'));
    await tester.pumpAndSettle();

    expect(find.text('Não foi possível carregar as marcas'), findsOneWidget);
    expect(find.textContaining('Sem conexão com a internet'), findsOneWidget);

    online = true;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();

    expect(find.text('108 marcas'), findsOneWidget);
  });

  testWidgets('busca ignora acentos e maiúsculas e avisa quando não encontra', (tester) async {
    await abrirApp(tester);
    await tester.tap(find.text('Cadastrar veículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Marca'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'CITROEN');
    await tester.pumpAndSettle();
    expect(find.text('Citroën'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'xyz');
    await tester.pumpAndSettle();
    expect(find.text('Nada encontrado'), findsOneWidget);
  });

  testWidgets('excluir o veículo pede confirmação e apaga os abastecimentos', (tester) async {
    await abrirApp(
      tester,
      veiculo: argo,
      abastecimentos: [
        abastecimento(id: '1', quilometragem: 1000, data: DateTime(2026, 11, 1)),
        abastecimento(id: '2', quilometragem: 1400, data: DateTime(2026, 11, 10)),
      ],
    );
    await tester.tap(find.text('Veículo'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Excluir veículo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('os 2 abastecimentos registrados'), findsOneWidget);

    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Meu veículo'), findsOneWidget);

    await tester.tap(find.text('Excluir veículo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Excluir'));
    await tester.pumpAndSettle();

    expect(find.byType(TelaBoasVindas), findsOneWidget);
    expect(find.text('Veículo e abastecimentos excluídos'), findsOneWidget);
    final reaberto = await ArmazenamentoLocal.abrir();
    expect(reaberto.lerVeiculo(), isNull);
    expect(reaberto.lerAbastecimentos(), isEmpty);
  });
}
