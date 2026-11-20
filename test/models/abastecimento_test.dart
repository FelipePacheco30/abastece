import 'package:abastece/models/abastecimento.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fixtures.dart';

void main() {
  final registro = abastecimento(
    id: '1',
    quilometragem: 12500,
    data: DateTime(2026, 11, 3, 18, 45),
    litros: 38.42,
    precoPorLitro: 5.89,
    combustivel: Combustivel.etanol,
  );

  test('valor total é o preço por litro vezes os litros', () {
    expect(registro.valorTotal, closeTo(226.2938, 1e-9));
  });

  test('converte para JSON e de volta sem perder dados', () {
    final copia = Abastecimento.deJson(registro.paraJson());

    expect(copia.id, '1');
    expect(copia.combustivel, Combustivel.etanol);
    expect(copia.precoPorLitro, 5.89);
    expect(copia.litros, 38.42);
    expect(copia.quilometragem, 12500);
    expect(copia.data, DateTime(2026, 11, 3, 18, 45));
  });

  test('ordena por data e, no mesmo horário, pela quilometragem', () {
    final data = DateTime(2026, 11, 1, 8);
    final lista = [
      abastecimento(id: 'c', quilometragem: 900, data: DateTime(2026, 11, 2)),
      abastecimento(id: 'b', quilometragem: 500, data: data),
      abastecimento(id: 'a', quilometragem: 100, data: data),
    ]..sort(Abastecimento.comparar);

    expect([for (final a in lista) a.id], ['a', 'b', 'c']);
  });
}
