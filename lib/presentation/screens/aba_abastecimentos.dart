import 'package:flutter/material.dart';

import '../../controllers/controlador_garagem.dart';
import '../../core/formatos.dart';
import '../../core/tema.dart';
import '../../models/historico.dart';
import '../widgets/icone_combustivel.dart';
import '../widgets/mensagem_estado.dart';
import 'tela_abastecimento.dart';

/// Abastecimentos do mais recente para o mais antigo, agrupados por mês.
class AbaAbastecimentos extends StatelessWidget {
  const AbaAbastecimentos({super.key, required this.garagem});

  final ControladorGaragem garagem;

  @override
  Widget build(BuildContext context) {
    final trechos = garagem.historico.trechos;
    if (trechos.isEmpty) {
      return const MensagemEstado(
        icone: Icons.local_gas_station_outlined,
        titulo: 'Nenhum abastecimento ainda',
        texto:
            'Toque em Abastecer para registrar o primeiro. O consumo e o custo por km '
            'aparecem a partir do segundo registro.',
      );
    }

    final meses = <DateTime, List<Trecho>>{};
    for (final trecho in trechos.reversed) {
      final data = trecho.abastecimento.data;
      meses.putIfAbsent(DateTime(data.year, data.month), () => []).add(trecho);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 104),
      children: [
        for (final MapEntry(key: mes, value: doMes) in meses.entries) ...[
          _CabecalhoMes(mes: mes, trechos: doMes),
          Card(
            child: Column(
              children: [
                for (final (indice, trecho) in doMes.indexed) ...[
                  if (indice > 0) const Divider(indent: 72),
                  _ItemAbastecimento(
                    trecho: trecho,
                    aoTocar: () => TelaAbastecimento.abrir(context, garagem, trecho.abastecimento),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _CabecalhoMes extends StatelessWidget {
  const _CabecalhoMes({required this.mes, required this.trechos});

  final DateTime mes;
  final List<Trecho> trechos;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final total = trechos.fold(0.0, (soma, t) => soma + t.abastecimento.valorTotal);

    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              formatarMesAno(mes),
              style: tema.textTheme.titleSmall,
              semanticsLabel: '${formatarMesAno(mes)}, total ${formatarMoeda(total)}',
            ),
          ),
          ExcludeSemantics(
            child: Text(
              formatarMoeda(total),
              style: tema.textTheme.bodyMedium?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
                fontFeatures: algarismosTabulares,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemAbastecimento extends StatelessWidget {
  const _ItemAbastecimento({required this.trecho, required this.aoTocar});

  final Trecho trecho;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final abastecimento = trecho.abastecimento;
    final secundario = tema.textTheme.bodySmall?.copyWith(
      color: cores.onSurfaceVariant,
      fontFeatures: algarismosTabulares,
    );
    final indicadores = switch ((trecho.kmPorLitro, trecho.custoPorKm)) {
      (final kmPorLitro?, final custoPorKm?) =>
        '${formatarKmPorLitro(kmPorLitro)} · ${formatarCustoPorKm(custoPorKm)}',
      _ => 'Primeiro registro, referência para o consumo',
    };

    return InkWell(
      onTap: aoTocar,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconeCombustivel(abastecimento.combustivel),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${formatarDiaSemana(abastecimento.data)} · '
                          '${formatarHora(abastecimento.data)}',
                          style: tema.textTheme.titleSmall,
                        ),
                      ),
                      Text(
                        formatarMoeda(abastecimento.valorTotal),
                        style: tema.textTheme.titleSmall?.copyWith(
                          fontFeatures: algarismosTabulares,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${abastecimento.combustivel.rotulo} · ${formatarLitros(abastecimento.litros)}'
                    ' × ${formatarPrecoLitro(abastecimento.precoPorLitro)}',
                    style: secundario,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatarKm(abastecimento.quilometragem)} · $indicadores',
                    style: secundario?.copyWith(
                      color: trecho.temIndicadores ? cores.onSurface : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
