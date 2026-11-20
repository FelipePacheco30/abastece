import 'dart:io';

import 'package:abastece/models/abastecimento.dart';
import 'package:abastece/models/veiculo.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Resposta real da BrasilAPI gravada em `test/fixtures`.
http.Response respostaBrasilApi(String arquivo) => http.Response.bytes(
  File('test/fixtures/$arquivo').readAsBytesSync(),
  200,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

/// BrasilAPI simulada: marcas de carros e modelos da Fiat (código 21).
MockClient brasilApiFalsa() => MockClient((requisicao) async {
  return switch (requisicao.url.path) {
    '/api/fipe/marcas/v1/carros' => respostaBrasilApi('marcas_carros.json'),
    '/api/fipe/veiculos/v1/carros/21' => respostaBrasilApi('modelos_fiat.json'),
    _ => http.Response('{"message":"Request failed with status code 500"}', 500),
  };
});

const argo = Veiculo(marca: 'Fiat', modelo: 'ARGO DRIVE 1.3 8V Flex', ano: 2022, cilindrada: 1.3);

Abastecimento abastecimento({
  required String id,
  required int quilometragem,
  required DateTime data,
  double litros = 40,
  double precoPorLitro = 5,
  Combustivel combustivel = Combustivel.gasolina,
}) => Abastecimento(
  id: id,
  combustivel: combustivel,
  precoPorLitro: precoPorLitro,
  litros: litros,
  quilometragem: quilometragem,
  data: data,
);

/// Três meses de abastecimentos de um Argo 1.3, alternando gasolina e etanol.
final historicoDeExemplo = [
  for (final (indice, (data, combustivel, preco, litros, km)) in [
    (DateTime(2026, 8, 2, 7, 40), Combustivel.gasolina, 6.19, 38.2, 18240),
    (DateTime(2026, 8, 16, 18, 15), Combustivel.gasolina, 6.24, 35.6, 18690),
    (DateTime(2026, 8, 30, 12, 5), Combustivel.etanol, 4.29, 41.8, 19050),
    (DateTime(2026, 9, 12, 19, 30), Combustivel.etanol, 4.35, 40.1, 19410),
    (DateTime(2026, 9, 27, 8, 50), Combustivel.gasolina, 6.29, 36.9, 19870),
    (DateTime(2026, 10, 10, 17, 20), Combustivel.gasolina, 6.27, 34.4, 20330),
    (DateTime(2026, 10, 24, 9, 10), Combustivel.gasolina, 6.34, 37.3, 20780),
    (DateTime(2026, 11, 7, 18, 45), Combustivel.etanol, 4.39, 42.6, 21150),
    (DateTime(2026, 11, 18, 7, 55), Combustivel.gasolina, 6.31, 35.1, 21610),
  ].indexed)
    Abastecimento(
      id: '${indice + 1}',
      combustivel: combustivel,
      precoPorLitro: preco,
      litros: litros,
      quilometragem: km,
      data: data,
    ),
];
