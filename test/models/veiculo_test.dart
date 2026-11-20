import 'package:abastece/models/veiculo.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  test('converte para JSON e de volta sem perder dados', () {
    final copia = Veiculo.deJson(argo.paraJson());

    expect(copia.marca, 'Fiat');
    expect(copia.modelo, 'ARGO DRIVE 1.3 8V Flex');
    expect(copia.ano, 2022);
    expect(copia.cilindrada, 1.3);
  });

  test('aceita cilindrada inteira gravada no JSON', () {
    final veiculo = Veiculo.deJson({...argo.paraJson(), 'cilindrada': 2});

    expect(veiculo.cilindrada, 2.0);
  });

  group('cilindradaDoModelo', () {
    final casos = {
      'ARGO DRIVE 1.3 8V Flex': 1.3,
      'Hilux CD SRV 2.8 4x4 TDI Diesel Aut.': 2.8,
      'Idea ESSENCE SUBLIME Dual.1.6 Flex16V 5p': 1.6,
      'Uno S 1.5 i.e. / 1.5 / 1.3/ SX 1.3': 1.5,
      'Gol 1,0 Mi 8V': 1.0,
    };
    for (final MapEntry(key: modelo, value: esperado) in casos.entries) {
      test('"$modelo" → $esperado', () {
        expect(Veiculo.cilindradaDoModelo(modelo), esperado);
      });
    }

    test('é nula quando o nome não informa a cilindrada', () {
      expect(Veiculo.cilindradaDoModelo('147 C/ CL'), isNull);
      expect(Veiculo.cilindradaDoModelo('PULSE AUDACE Turbo 200  Aut. (Hibrído)'), isNull);
      expect(Veiculo.cilindradaDoModelo('Corolla 12.5'), isNull);
    });
  });
}
