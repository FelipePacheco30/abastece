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
