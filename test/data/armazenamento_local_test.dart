import 'package:abastece/data/armazenamento_local.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/armazenamento_em_memoria.dart';
import '../support/fixtures.dart';

void main() {
  final registros = [
    abastecimento(id: '1', quilometragem: 1000, data: DateTime(2026, 10, 1, 7, 30)),
    abastecimento(id: '2', quilometragem: 1450, data: DateTime(2026, 10, 12, 19, 5)),
  ];

  test('começa sem veículo e sem abastecimentos', () async {
    final armazenamento = await armazenamentoEmMemoria();

    expect(armazenamento.lerVeiculo(), isNull);
    expect(armazenamento.lerAbastecimentos(), isEmpty);
  });

  test('mantém os dados ao reabrir o armazenamento', () async {
    final armazenamento = await armazenamentoEmMemoria();
    await armazenamento.salvarVeiculo(argo);
    await armazenamento.salvarAbastecimentos(registros);

    final reaberto = await ArmazenamentoLocal.abrir();

    expect(reaberto.lerVeiculo()?.modelo, argo.modelo);
    expect([for (final a in reaberto.lerAbastecimentos()) a.id], ['1', '2']);
    expect(reaberto.lerAbastecimentos().last.data, DateTime(2026, 10, 12, 19, 5));
  });

  test('excluir o veículo remove também os abastecimentos', () async {
    final armazenamento = await armazenamentoEmMemoria();
    await armazenamento.salvarVeiculo(argo);
    await armazenamento.salvarAbastecimentos(registros);

    await armazenamento.excluirVeiculo();
    final reaberto = await ArmazenamentoLocal.abrir();

    expect(reaberto.lerVeiculo(), isNull);
    expect(reaberto.lerAbastecimentos(), isEmpty);
  });

  test('descarta só os abastecimentos corrompidos', () async {
    final armazenamento = await armazenamentoEmMemoria({
      'abastecimentos':
          '[{"id": "1", "combustivel": "etanol", "precoPorLitro": 5, "litros": 40,'
          ' "quilometragem": 100, "data": "2026-10-01T00:00:00.000"},'
          ' {"id": "2", "litros": "40"}, 7]',
    });

    expect([for (final a in armazenamento.lerAbastecimentos()) a.id], ['1']);
  });

  group('ignora dados corrompidos', () {
    final casos = {
      'texto que não é JSON': {'veiculo': '{marca', 'abastecimentos': '[{'},
      'formato inesperado': {'veiculo': '[]', 'abastecimentos': '{}'},
      'campos com tipo errado': {
        'veiculo': '{"marca": 1, "modelo": "Argo", "ano": 2022, "cilindrada": 1.3}',
        'abastecimentos': '[{"id": "1", "litros": "40"}]',
      },
      'combustível desconhecido': {
        'abastecimentos':
            '[{"id": "1", "combustivel": "gnv", "precoPorLitro": 5, "litros": 40,'
            ' "quilometragem": 100, "data": "2026-10-01T00:00:00.000"}]',
      },
      'data inválida': {
        'abastecimentos':
            '[{"id": "1", "combustivel": "etanol", "precoPorLitro": 5, "litros": 40,'
            ' "quilometragem": 100, "data": "ontem"}]',
      },
    };

    for (final MapEntry(key: descricao, value: dados) in casos.entries) {
      test(descricao, () async {
        final armazenamento = await armazenamentoEmMemoria(dados);

        expect(armazenamento.lerVeiculo(), isNull);
        expect(armazenamento.lerAbastecimentos(), isEmpty);
      });
    }
  });
}
