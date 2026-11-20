import 'package:flutter/foundation.dart';

import '../data/armazenamento_local.dart';
import '../models/historico.dart';
import '../models/veiculo.dart';

/// Estado do veículo cadastrado e dos seus abastecimentos, compartilhado
/// entre as telas. Toda alteração é gravada antes de ser exibida.
class ControladorGaragem extends ChangeNotifier {
  ControladorGaragem(this._armazenamento)
    : _veiculo = _armazenamento.lerVeiculo(),
      _historico = Historico(_armazenamento.lerAbastecimentos());

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
}
