import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/opcao_fipe.dart';
import 'falhas.dart';

/// Consulta marcas e modelos de carros da tabela FIPE pela BrasilAPI.
///
/// As listas obtidas ficam em memória enquanto o app está aberto, para que
/// reabrir a seleção não repita a requisição.
class ClienteBrasilApi {
  ClienteBrasilApi({http.Client? cliente, this.tempoLimite = const Duration(seconds: 15)})
    : _cliente = cliente ?? http.Client();

  final http.Client _cliente;
  final Duration tempoLimite;
  final _cache = <String, List<OpcaoFipe>>{};

  Future<List<OpcaoFipe>> buscarMarcas() => _consultar('marcas/v1/carros', campoNome: 'nome');

  Future<List<OpcaoFipe>> buscarModelos(String codigoMarca) =>
      _consultar('veiculos/v1/carros/$codigoMarca', campoNome: 'modelo');

  Future<List<OpcaoFipe>> _consultar(String caminho, {required String campoNome}) async {
    return _cache[caminho] ??= _ler(await _baixar(caminho), campoNome);
  }

  Future<http.Response> _baixar(String caminho) async {
    final endereco = Uri.https('brasilapi.com.br', '/api/fipe/$caminho');
    final http.Response resposta;
    try {
      resposta = await _cliente.get(endereco).timeout(tempoLimite);
    } on TimeoutException {
      throw const FalhaConexao();
    } on http.ClientException {
      throw const FalhaConexao();
    }
    if (resposta.statusCode != 200) throw const ServicoIndisponivel();
    return resposta;
  }

  List<OpcaoFipe> _ler(http.Response resposta, String campoNome) {
    try {
      final itens = jsonDecode(utf8.decode(resposta.bodyBytes)) as List<Object?>;
      return [
        for (final item in itens.cast<Map<String, Object?>>())
          OpcaoFipe(codigo: item['valor'] as String, nome: (item[campoNome] as String).trim()),
      ];
    } on FormatException {
      throw const RespostaInvalida();
    } on TypeError {
      throw const RespostaInvalida();
    }
  }
}
