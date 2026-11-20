import 'package:abastece/models/historico.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  final primeiro = abastecimento(
    id: '1',
    quilometragem: 10000,
    data: DateTime(2026, 10, 1),
    litros: 40,
    precoPorLitro: 6,
  );
  final segundo = abastecimento(
    id: '2',
    quilometragem: 10500,
    data: DateTime(2026, 10, 15),
    litros: 40,
    precoPorLitro: 6,
  );
  final terceiro = abastecimento(
    id: '3',
    quilometragem: 11100,
    data: DateTime(2026, 11, 1),
    litros: 50,
    precoPorLitro: 5,
  );

  test('sem abastecimentos não há indicadores', () {
    final historico = Historico([]);

    expect(historico.vazio, isTrue);
    expect(historico.gastoTotal, 0);
    expect(historico.distanciaTotal, 0);
    expect(historico.consumoMedio, isNull);
    expect(historico.custoMedioPorKm, isNull);
  });

  test('o primeiro abastecimento serve só de referência', () {
    final historico = Historico([primeiro]);
    final trecho = historico.trechos.single;

    expect(trecho.temIndicadores, isFalse);
    expect(trecho.distancia, isNull);
    expect(trecho.kmPorLitro, isNull);
    expect(trecho.custoPorKm, isNull);
    expect(historico.gastoTotal, 240);
    expect(historico.consumoMedio, isNull);
  });

  test('calcula distância, km/L e R\$/km a partir do segundo abastecimento', () {
    final trecho = Historico([primeiro, segundo]).trechos.last;

    expect(trecho.distancia, 500);
    expect(trecho.kmPorLitro, 12.5);
    expect(trecho.custoPorKm, closeTo(0.48, 1e-9));
  });

  test('ordena os abastecimentos cronologicamente antes de calcular', () {
    final historico = Historico([terceiro, primeiro, segundo]);

    expect([for (final t in historico.trechos) t.abastecimento.id], ['1', '2', '3']);
    expect(historico.trechos.last.distancia, 600);
    expect(historico.trechos.last.kmPorLitro, 12);
  });

  test('médias são ponderadas pela distância e ignoram o primeiro registro', () {
    final historico = Historico([primeiro, segundo, terceiro]);

    expect(historico.gastoTotal, 730);
    expect(historico.distanciaTotal, 1100);
    expect(historico.consumoMedio, closeTo(1100 / 90, 1e-9));
    expect(historico.custoMedioPorKm, closeTo(490 / 1100, 1e-9));
    expect(historico.comIndicadores, hasLength(2));
  });

  group('vizinhos', () {
    final historico = Historico([primeiro, segundo, terceiro]);

    test('encontra o anterior e o próximo de uma data intermediária', () {
      final vizinhos = historico.vizinhos(DateTime(2026, 10, 20));

      expect(vizinhos.anterior, segundo);
      expect(vizinhos.proximo, terceiro);
    });

    test('não há anterior antes do primeiro nem próximo depois do último', () {
      expect(historico.vizinhos(DateTime(2026, 9, 1)).anterior, isNull);
      expect(historico.vizinhos(DateTime(2026, 12, 1)).proximo, isNull);
    });

    test('ignora o registro em edição', () {
      final vizinhos = historico.vizinhos(DateTime(2026, 10, 15), ignorar: '2');

      expect(vizinhos.anterior, primeiro);
      expect(vizinhos.proximo, terceiro);
    });
  });
}
