import 'dart:async';

import 'package:abastece/data/cliente_brasil_api.dart';
import 'package:abastece/data/falhas.dart';
import 'package:abastece/models/opcao_fipe.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import '../support/fixtures.dart';

void main() {
  test('busca as marcas de carros', () async {
    final marcas = await ClienteBrasilApi(cliente: brasilApiFalsa()).buscarMarcas();

    expect(marcas, hasLength(108));
    expect(marcas, contains(const OpcaoFipe(codigo: '21', nome: 'Fiat')));
  });

  test('busca os modelos da marca escolhida', () async {
    final modelos = await ClienteBrasilApi(cliente: brasilApiFalsa()).buscarModelos('21');

    expect(modelos, hasLength(586));
    expect(modelos.map((m) => m.nome), contains('ARGO DRIVE 1.3 8V Flex'));
    expect(modelos.map((m) => m.nome), contains('147 Furgão (todos)'));
  });

  test('consulta os endereços da tabela FIPE na BrasilAPI', () async {
    final enderecos = <Uri>[];
    final cliente = ClienteBrasilApi(
      cliente: MockClient((requisicao) async {
        enderecos.add(requisicao.url);
        return http.Response('[]', 200);
      }),
    );

    await cliente.buscarMarcas();
    await cliente.buscarModelos('21');

    expect(enderecos, [
      Uri.parse('https://brasilapi.com.br/api/fipe/marcas/v1/carros'),
      Uri.parse('https://brasilapi.com.br/api/fipe/veiculos/v1/carros/21'),
    ]);
  });

  test('reaproveita listas já obtidas e repete consultas que falharam', () async {
    var requisicoes = 0;
    var online = false;
    final cliente = ClienteBrasilApi(
      cliente: MockClient((requisicao) async {
        requisicoes++;
        if (!online) throw http.ClientException('sem rede');
        return respostaBrasilApi('marcas_carros.json');
      }),
    );

    await expectLater(cliente.buscarMarcas(), throwsA(isA<FalhaConexao>()));
    online = true;
    await cliente.buscarMarcas();
    await cliente.buscarMarcas();

    expect(requisicoes, 2);
  });

  group('falhas', () {
    Future<List<OpcaoFipe>> consultar(Future<http.Response> Function() responder) {
      return ClienteBrasilApi(
        cliente: MockClient((_) => responder()),
        tempoLimite: const Duration(milliseconds: 50),
      ).buscarMarcas();
    }

    test('sem conexão', () {
      expect(consultar(() => throw http.ClientException('falhou')), throwsA(isA<FalhaConexao>()));
    });

    test('tempo esgotado', () {
      expect(consultar(() => Completer<http.Response>().future), throwsA(isA<FalhaConexao>()));
    });

    test('erro no servidor', () {
      expect(
        consultar(() async => http.Response('{"type":"internal_error"}', 500)),
        throwsA(isA<ServicoIndisponivel>()),
      );
    });

    test('limite de requisições', () {
      expect(consultar(() async => http.Response('', 429)), throwsA(isA<ServicoIndisponivel>()));
    });

    test('corpo que não é JSON', () {
      expect(
        consultar(() async => http.Response('<html></html>', 200)),
        throwsA(isA<RespostaInvalida>()),
      );
    });

    test('JSON com formato inesperado', () {
      expect(
        consultar(() async => http.Response('[{"nome": "Fiat"}]', 200)),
        throwsA(isA<RespostaInvalida>()),
      );
      expect(
        consultar(() async => http.Response('{"marcas": []}', 200)),
        throwsA(isA<RespostaInvalida>()),
      );
    });
  });
}
