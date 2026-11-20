import 'package:abastece/controllers/controlador_garagem.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/armazenamento_em_memoria.dart';
import '../support/fixtures.dart';

void main() {
  test('carrega o veículo e os abastecimentos gravados', () async {
    final armazenamento = await armazenamentoEmMemoria();
    await armazenamento.salvarVeiculo(argo);
    await armazenamento.salvarAbastecimentos(historicoDeExemplo);

    final garagem = ControladorGaragem(armazenamento);

    expect(garagem.veiculo?.modelo, argo.modelo);
    expect(garagem.historico.trechos, hasLength(historicoDeExemplo.length));
  });

  test('ignora abastecimentos gravados sem um veículo válido', () async {
    final armazenamento = await armazenamentoEmMemoria({'veiculo': '{corrompido'});
    await armazenamento.salvarAbastecimentos(historicoDeExemplo);

    final garagem = ControladorGaragem(armazenamento);
    await garagem.cadastrarVeiculo(argo);

    expect(garagem.historico.vazio, isTrue);
  });

  test('salvar substitui o abastecimento com o mesmo id e mantém a ordem', () async {
    final garagem = ControladorGaragem(await armazenamentoEmMemoria());
    await garagem.cadastrarVeiculo(argo);
    final primeiro = abastecimento(id: 'a', quilometragem: 100, data: DateTime(2026, 10, 2));
    final segundo = abastecimento(id: 'b', quilometragem: 500, data: DateTime(2026, 10, 9));

    await garagem.salvarAbastecimento(segundo);
    await garagem.salvarAbastecimento(primeiro);
    await garagem.salvarAbastecimento(
      abastecimento(id: 'b', quilometragem: 600, data: DateTime(2026, 10, 9)),
    );

    expect([for (final t in garagem.historico.trechos) t.abastecimento.id], ['a', 'b']);
    expect(garagem.historico.trechos.last.distancia, 500);
  });

  test('notifica a interface a cada alteração', () async {
    final garagem = ControladorGaragem(await armazenamentoEmMemoria());
    var notificacoes = 0;
    garagem.addListener(() => notificacoes++);

    await garagem.cadastrarVeiculo(argo);
    await garagem.salvarAbastecimento(historicoDeExemplo.first);
    await garagem.excluirAbastecimento(historicoDeExemplo.first.id);
    await garagem.excluirVeiculo();

    expect(notificacoes, 4);
    expect(garagem.veiculo, isNull);
  });
}
