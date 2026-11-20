import 'package:flutter/foundation.dart';

import '../data/armazenamento_local.dart';
import '../models/abastecimento.dart';
import '../models/historico.dart';
import '../models/veiculo.dart';

/// Estado do veículo cadastrado e dos seus abastecimentos, compartilhado
/// entre as telas. Toda alteração é gravada antes de ser exibida.
class ControladorGaragem extends ChangeNotifier {
  /// Abastecimentos só são carregados junto com um veículo válido, para que
  /// registros órfãos nunca apareçam sob um novo cadastro.
  ControladorGaragem(this._armazenamento)
    : _veiculo = _armazenamento.lerVeiculo(),
      _historico = Historico(const []) {
    if (_veiculo != null) _historico = Historico(_armazenamento.lerAbastecimentos());
  }

  final ArmazenamentoLocal _armazenamento;
  Veiculo? _veiculo;
  Historico _historico;

  Veiculo? get veiculo => _veiculo;
  Historico get historico => _historico;

  Future<void> cadastrarVeiculo(Veiculo veiculo) async {
    await _armazenamento.salvarVeiculo(veiculo);
    _veiculo = veiculo;
    notifyListeners();
  }

  Future<void> excluirVeiculo() async {
    await _armazenamento.excluirVeiculo();
    _veiculo = null;
    _historico = Historico(const []);
    notifyListeners();
  }

  /// Registra um abastecimento ou substitui o que tem o mesmo `id`.
  Future<void> salvarAbastecimento(Abastecimento abastecimento) => _gravarAbastecimentos([
    for (final a in _historico.abastecimentos)
      if (a.id != abastecimento.id) a,
    abastecimento,
  ]);

  Future<void> excluirAbastecimento(String id) => _gravarAbastecimentos([
    for (final a in _historico.abastecimentos)
      if (a.id != id) a,
  ]);

  Future<void> _gravarAbastecimentos(List<Abastecimento> abastecimentos) async {
    final historico = Historico(abastecimentos);
    await _armazenamento.salvarAbastecimentos(historico.abastecimentos);
    _historico = historico;
    notifyListeners();
  }
}
