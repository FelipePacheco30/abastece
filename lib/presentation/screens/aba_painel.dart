import 'package:flutter/material.dart';

import '../../controllers/controlador_garagem.dart';
import '../../core/formatos.dart';
import '../../core/tema.dart';
import '../../models/historico.dart';
import '../widgets/graficos.dart';
import '../widgets/mensagem_estado.dart';

/// Indicadores gerais e gráficos de valor, consumo e custo por km.
class AbaPainel extends StatelessWidget {
  const AbaPainel({super.key, required this.garagem});

  final ControladorGaragem garagem;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final veiculo = garagem.veiculo!;
    final historico = garagem.historico;

    if (historico.vazio) {
      return const MensagemEstado(
        icone: Icons.insights_rounded,
        titulo: 'Seu painel aparece aqui',
        texto:
            'Toque em Abastecer para registrar o primeiro abastecimento. Os gráficos de '
            'consumo e de custo por km começam a partir do segundo.',
      );
    }

    final trechos = historico.trechos;
    final comIndicadores = historico.comIndicadores.toList();
    final ultimo = comIndicadores.lastOrNull;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 104),
      children: [
        Text(
          '${veiculo.marca} ${veiculo.modelo} · ${veiculo.ano}',
          style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        _Indicadores(historico: historico),
        const SizedBox(height: 16),
        if (ultimo == null) ...[const _AvisoSegundoAbastecimento(), const SizedBox(height: 16)],
        _CartaoGrafico(
          titulo: 'Valor por abastecimento',
          destaque: formatarMoeda(trechos.last.abastecimento.valorTotal),
          detalhe: 'último · média ${formatarMoeda(historico.gastoTotal / trechos.length)}',
          rodape: LegendaCombustiveis(
            combustiveis: {for (final t in trechos) t.abastecimento.combustivel},
          ),
          grafico: GraficoValores(trechos: trechos),
        ),
        const SizedBox(height: 16),
        if (ultimo != null) ...[
          _CartaoGrafico(
            titulo: 'Consumo (km/L)',
            destaque: formatarKmPorLitro(ultimo.kmPorLitro!),
            detalhe: 'último trecho · média ${formatarKmPorLitro(historico.consumoMedio!)}',
            grafico: GraficoEvolucao(
              pontos: [
                for (final t in comIndicadores) (data: t.abastecimento.data, valor: t.kmPorLitro!),
              ],
              media: historico.consumoMedio!,
              formatar: formatarKmPorLitro,
              casasEixo: 0,
            ),
            rodape: const LegendaEvolucao(),
          ),
          const SizedBox(height: 16),
          _CartaoGrafico(
            titulo: 'Custo por km (R\$/km)',
            destaque: formatarCustoPorKm(ultimo.custoPorKm!),
            detalhe: 'último trecho · média ${formatarCustoPorKm(historico.custoMedioPorKm!)}',
            grafico: GraficoEvolucao(
              pontos: [
                for (final t in comIndicadores) (data: t.abastecimento.data, valor: t.custoPorKm!),
              ],
              media: historico.custoMedioPorKm!,
              formatar: formatarCustoPorKm,
              casasEixo: 2,
            ),
            rodape: const LegendaEvolucao(),
          ),
        ],
      ],
    );
  }
}

class _Indicadores extends StatelessWidget {
  const _Indicadores({required this.historico});

  final Historico historico;

  @override
  Widget build(BuildContext context) {
    final quantidade = historico.trechos.length;
    final inicio = historico.trechos.first.abastecimento.data;
    final (consumo, custo) = (historico.consumoMedio, historico.custoMedioPorKm);
    const aPartirDoSegundo = 'a partir do 2º registro';

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Indicador(
                icone: Icons.payments_outlined,
                rotulo: 'Gasto total',
                valor: formatarMoeda(historico.gastoTotal),
                detalhe: quantidade == 1 ? '1 abastecimento' : '$quantidade abastecimentos',
              ),
              const SizedBox(width: 12),
              _Indicador(
                icone: Icons.route_outlined,
                rotulo: 'Distância',
                valor: formatarKm(historico.distanciaTotal),
                detalhe: 'desde ${formatarData(inicio)}',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Indicador(
                icone: Icons.speed_rounded,
                rotulo: 'Consumo médio',
                valor: consumo == null ? '—' : formatarKmPorLitro(consumo),
                detalhe: consumo == null ? aPartirDoSegundo : 'no período',
              ),
              const SizedBox(width: 12),
              _Indicador(
                icone: Icons.local_atm_outlined,
                rotulo: 'Custo por km',
                valor: custo == null ? '—' : formatarCustoPorKm(custo),
                detalhe: custo == null ? aPartirDoSegundo : 'no período',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Indicador extends StatelessWidget {
  const _Indicador({
    required this.icone,
    required this.rotulo,
    required this.valor,
    required this.detalhe,
  });

  final IconData icone;
  final String rotulo;
  final String valor;
  final String detalhe;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secundario = tema.colorScheme.onSurfaceVariant;

    return Expanded(
      child: Card(
        child: MergeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icone, size: 18, color: secundario),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        rotulo,
                        style: tema.textTheme.bodySmall?.copyWith(color: secundario),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    valor,
                    style: tema.textTheme.titleLarge?.copyWith(fontFeatures: algarismosTabulares),
                  ),
                ),
                const SizedBox(height: 2),
                Text(detalhe, style: tema.textTheme.bodySmall?.copyWith(color: secundario)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CartaoGrafico extends StatelessWidget {
  const _CartaoGrafico({
    required this.titulo,
    required this.destaque,
    required this.detalhe,
    required this.grafico,
    this.rodape,
  });

  final String titulo;
  final String destaque;
  final String detalhe;
  final Widget grafico;
  final Widget? rodape;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final secundario = tema.colorScheme.onSurfaceVariant;

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MergeSemantics(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: tema.textTheme.titleSmall),
                  const SizedBox(height: 8),
                  Text(
                    destaque,
                    style: tema.textTheme.headlineSmall?.copyWith(
                      fontFeatures: algarismosTabulares,
                    ),
                  ),
                  Text(detalhe, style: tema.textTheme.bodySmall?.copyWith(color: secundario)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ExcludeSemantics(child: SizedBox(height: 180, child: grafico)),
            if (rodape case final rodape?) ...[const SizedBox(height: 12), rodape],
          ],
        ),
      ),
    );
  }
}

class _AvisoSegundoAbastecimento extends StatelessWidget {
  const _AvisoSegundoAbastecimento();

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cores.primaryContainer, borderRadius: raioCartao),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: cores.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'O primeiro abastecimento é a referência. No próximo, registrando a '
              'quilometragem, o app calcula o consumo em km/L e o custo por km.',
              style: tema.textTheme.bodyMedium?.copyWith(color: cores.onPrimaryContainer),
            ),
          ),
        ],
      ),
    );
  }
}
