import 'package:flutter/material.dart';

import '../../controllers/controlador_garagem.dart';
import '../../core/formatos.dart';
import '../../core/tema.dart';
import '../../models/veiculo.dart';
import '../widgets/aviso.dart';
import '../widgets/confirmacao.dart';

/// Dados do veículo cadastrado e a opção de excluí-lo.
class AbaVeiculo extends StatelessWidget {
  const AbaVeiculo({super.key, required this.garagem});

  final ControladorGaragem garagem;

  Future<void> _excluir(BuildContext context, Veiculo veiculo) async {
    final mensageiro = ScaffoldMessenger.of(context);
    final confirmado = await confirmarExclusao(
      context,
      titulo: 'Excluir veículo?',
      mensagem: _mensagemExclusao(veiculo, garagem.historico.trechos.length),
    );
    if (!confirmado) return;

    await garagem.excluirVeiculo();
    mensageiro.avisar('Veículo e abastecimentos excluídos');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final veiculo = garagem.veiculo!;
    final trechos = garagem.historico.trechos;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cores.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.directions_car_rounded, color: cores.onPrimaryContainer),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            veiculo.marca,
                            style: tema.textTheme.labelLarge?.copyWith(
                              color: cores.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(veiculo.modelo, style: tema.textTheme.titleMedium),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        _Informacao(rotulo: 'Ano', valor: '${veiculo.ano}'),
                        _Informacao(
                          rotulo: 'Cilindrada',
                          valor: formatarCilindrada(veiculo.cilindrada),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _Informacao(rotulo: 'Abastecimentos', valor: '${trechos.length}'),
                        _Informacao(
                          rotulo: 'Último hodômetro',
                          valor: trechos.isEmpty
                              ? '—'
                              : formatarKm(trechos.last.abastecimento.quilometragem),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Text('Trocar de veículo', style: tema.textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(
          'O app acompanha um veículo por vez. Para cadastrar outro, exclua este — os '
          'abastecimentos dele também serão apagados.',
          style: tema.textTheme.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: () => _excluir(context, veiculo),
          style: OutlinedButton.styleFrom(
            foregroundColor: cores.error,
            side: BorderSide(color: cores.error.withValues(alpha: 0.5)),
          ),
          icon: const Icon(Icons.delete_outline_rounded),
          label: const Text('Excluir veículo'),
        ),
      ],
    );
  }
}

class _Informacao extends StatelessWidget {
  const _Informacao({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Expanded(
      child: MergeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rotulo,
              style: tema.textTheme.bodySmall?.copyWith(color: tema.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 2),
            Text(
              valor,
              style: tema.textTheme.titleMedium?.copyWith(fontFeatures: algarismosTabulares),
            ),
          ],
        ),
      ),
    );
  }
}

String _mensagemExclusao(Veiculo veiculo, int abastecimentos) {
  final nome = '${veiculo.marca} ${veiculo.modelo}';
  return switch (abastecimentos) {
    0 => 'O $nome será apagado deste aparelho.',
    1 => 'O $nome e o abastecimento registrado serão apagados deste aparelho.',
    final n => 'O $nome e os $n abastecimentos registrados serão apagados deste aparelho.',
  };
}
