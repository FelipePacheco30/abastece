import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/formatos.dart';
import '../../core/tema.dart';
import '../../models/abastecimento.dart';
import '../../models/historico.dart';

/// Valor de cada abastecimento, com a barra na cor do combustível.
class GraficoValores extends StatelessWidget {
  const GraficoValores({super.key, required this.trechos});

  final List<Trecho> trechos;

  @override
  Widget build(BuildContext context) {
    final estilo = _EstiloGrafico(context);
    final cores = CoresApp.de(context);
    final maior = trechos.map((t) => t.abastecimento.valorTotal).reduce(math.max);
    final intervalo = _intervaloRedondo(maior);

    return LayoutBuilder(
      builder: (context, limites) {
        final areaDasBarras = limites.maxWidth - _larguraEixoY;
        final largura = math.min(areaDasBarras / trechos.length * 0.5, 24.0);
        return BarChart(
          BarChartData(
            maxY: maior * 1.1,
            alignment: BarChartAlignment.spaceAround,
            gridData: estilo.grade(intervalo),
            borderData: FlBorderData(show: false),
            titlesData: estilo.titulos(
              intervalo: intervalo,
              datas: [for (final t in trechos) t.abastecimento.data],
              rotuloY: (valor) => formatarNumero(valor, casas: 0),
            ),
            barGroups: [
              for (final (indice, trecho) in trechos.indexed)
                BarChartGroupData(
                  x: indice,
                  barRods: [
                    BarChartRodData(
                      toY: trecho.abastecimento.valorTotal,
                      color: cores.combustivel(trecho.abastecimento.combustivel),
                      width: largura,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                ),
            ],
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => estilo.fundoDica,
                tooltipBorderRadius: estilo.cantosDica,
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                maxContentWidth: 160,
                getTooltipItem: (grupo, _, _, _) {
                  final abastecimento = trechos[grupo.x].abastecimento;
                  return estilo.dicaBarra(
                    '${formatarData(abastecimento.data)} · ${abastecimento.combustivel.rotulo}',
                    formatarMoeda(abastecimento.valorTotal),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Evolução de um indicador ao longo dos abastecimentos, com a média do
/// período como referência tracejada.
class GraficoEvolucao extends StatelessWidget {
  const GraficoEvolucao({
    super.key,
    required this.pontos,
    required this.media,
    required this.formatar,
    required this.casasEixo,
  });

  final List<({DateTime data, double valor})> pontos;
  final double media;
  final String Function(double valor) formatar;

  /// Casas decimais dos rótulos do eixo vertical.
  final int casasEixo;

  @override
  Widget build(BuildContext context) {
    final estilo = _EstiloGrafico(context);
    final cor = Theme.of(context).colorScheme.primary;
    final valores = pontos.map((p) => p.valor);
    final menor = valores.reduce(math.min);
    final maior = valores.reduce(math.max);
    final folga = math.max((maior - menor) * 0.2, maior * 0.05);
    final intervalo = _intervaloRedondo(maior - menor + 2 * folga);
    final minY = math.max(0.0, menor - folga);
    final maxY = maior + folga;

    return LineChart(
      LineChartData(
        minX: -0.3,
        maxX: pontos.length - 0.7,
        minY: minY,
        maxY: maxY,
        gridData: estilo.grade(intervalo),
        borderData: FlBorderData(show: false),
        titlesData: estilo.titulos(
          intervalo: intervalo,
          datas: [for (final p in pontos) p.data],
          rotuloY: (valor) => formatarNumero(valor, casas: casasEixo),
        ),
        extraLinesData: ExtraLinesData(
          horizontalLines: [
            HorizontalLine(
              y: media,
              color: estilo.textoSecundario,
              strokeWidth: 1,
              dashArray: tracejadoMedia,
            ),
          ],
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [for (final (i, p) in pontos.indexed) FlSpot(i.toDouble(), p.valor)],
            color: cor,
            barWidth: 2,
            isStrokeCapRound: true,
            isStrokeJoinRound: true,
            dotData: FlDotData(
              getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                radius: 4,
                color: cor,
                strokeWidth: 2,
                strokeColor: estilo.superficie,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (_) => estilo.fundoDica,
            tooltipBorderRadius: estilo.cantosDica,
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            getTooltipItems: (tocados) => [
              for (final ponto in tocados)
                estilo.dicaLinha(formatarData(pontos[ponto.x.toInt()].data), formatar(ponto.y)),
            ],
          ),
          getTouchedSpotIndicator: (_, indices) => [
            for (final _ in indices)
              TouchedSpotIndicatorData(
                FlLine(color: estilo.textoSecundario.withValues(alpha: 0.4), strokeWidth: 1),
                const FlDotData(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Grade, eixos e dicas comuns aos gráficos: discretos, para os dados se destacarem.
class _EstiloGrafico {
  _EstiloGrafico(BuildContext context) : _tema = Theme.of(context);

  final ThemeData _tema;

  ColorScheme get _cores => _tema.colorScheme;
  Color get superficie => _cores.surfaceContainerLowest;
  Color get textoSecundario => _cores.onSurfaceVariant;
  Color get fundoDica => _cores.inverseSurface;
  BorderRadius get cantosDica => BorderRadius.circular(8);

  TextStyle get rotulo => _tema.textTheme.labelSmall!.copyWith(
    color: textoSecundario,
    fontFeatures: algarismosTabulares,
  );

  FlGridData grade(double intervalo) => FlGridData(
    drawVerticalLine: false,
    horizontalInterval: intervalo,
    checkToShowHorizontalLine: (valor) => _multiplo(valor, intervalo),
    getDrawingHorizontalLine: (_) => FlLine(color: _cores.outlineVariant, strokeWidth: 1),
  );

  /// Datas no eixo horizontal (no máximo cinco, para não se sobreporem) e
  /// valores no vertical; as unidades ficam no título do cartão.
  FlTitlesData titulos({
    required double intervalo,
    required List<DateTime> datas,
    required String Function(double valor) rotuloY,
  }) {
    final passo = (datas.length / 5).ceil();
    return FlTitlesData(
      topTitles: const AxisTitles(),
      rightTitles: const AxisTitles(),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: _larguraEixoY,
          interval: intervalo,
          getTitlesWidget: (valor, meta) => valor == meta.max || valor == meta.min && valor != 0
              ? const SizedBox.shrink()
              : SideTitleWidget(
                  meta: meta,
                  child: Text(rotuloY(valor), style: rotulo),
                ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 28,
          interval: 1,
          getTitlesWidget: (valor, meta) {
            final indice = valor.round();
            final visivel = valor == indice && indice >= 0 && indice < datas.length;
            final ultimo = datas.length - 1;
            if (!visivel || (indice % passo != 0 && indice != ultimo)) {
              return const SizedBox.shrink();
            }
            if (indice != ultimo && ultimo - indice < passo) return const SizedBox.shrink();
            return SideTitleWidget(
              meta: meta,
              child: Text(formatarDiaMes(datas[indice]), style: rotulo),
            );
          },
        ),
      ),
    );
  }

  BarTooltipItem dicaBarra(String titulo, String valor) {
    final (texto, estilo, valorFormatado) = _dica(titulo, valor);
    return BarTooltipItem(texto, estilo, children: [valorFormatado]);
  }

  LineTooltipItem dicaLinha(String titulo, String valor) {
    final (texto, estilo, valorFormatado) = _dica(titulo, valor);
    return LineTooltipItem(texto, estilo, children: [valorFormatado]);
  }

  (String, TextStyle, TextSpan) _dica(String titulo, String valor) => (
    '$titulo\n',
    _tema.textTheme.labelSmall!.copyWith(color: _cores.onInverseSurface.withValues(alpha: 0.75)),
    TextSpan(
      text: valor,
      style: _tema.textTheme.labelLarge!.copyWith(
        color: _cores.onInverseSurface,
        fontFeatures: algarismosTabulares,
      ),
    ),
  );
}

const _larguraEixoY = 40.0;

/// Tracejado da linha de média, repetido na legenda.
const tracejadoMedia = [4, 4];

/// Intervalo "redondo" (1, 2 ou 5 × 10ⁿ) que divide [amplitude] em até
/// quatro faixas, para as linhas de grade caírem em valores legíveis.
double _intervaloRedondo(double amplitude) {
  if (amplitude <= 0) return 1;
  final bruto = amplitude / 4;
  final potencia = math.pow(10, (math.log(bruto) / math.ln10).floor()).toDouble();
  final fator = bruto / potencia;
  final redondo = switch (fator) {
    <= 1 => 1,
    <= 2 => 2,
    <= 5 => 5,
    _ => 10,
  };
  return redondo * potencia;
}

/// Grade e rótulos só nos múltiplos do intervalo, nunca nas bordas da escala.
bool _multiplo(double valor, double intervalo) {
  final razao = valor / intervalo;
  return (razao - razao.round()).abs() < 1e-6;
}

/// Legenda dos gráficos de evolução: valor de cada trecho e média do período.
class LegendaEvolucao extends StatelessWidget {
  const LegendaEvolucao({super.key});

  @override
  Widget build(BuildContext context) {
    final cores = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        _ItemLegenda(
          amostra: Container(width: 16, height: 2, color: cores.primary),
          rotulo: 'Por trecho',
        ),
        _ItemLegenda(
          amostra: CustomPaint(
            size: const Size(16, 2),
            painter: _Tracejado(cores.onSurfaceVariant),
          ),
          rotulo: 'Média do período',
        ),
      ],
    );
  }
}

/// Legenda das cores dos combustíveis presentes no gráfico de valores.
class LegendaCombustiveis extends StatelessWidget {
  const LegendaCombustiveis({super.key, required this.combustiveis});

  final Set<Combustivel> combustiveis;

  @override
  Widget build(BuildContext context) {
    final cores = CoresApp.de(context);

    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        for (final combustivel in Combustivel.values)
          if (combustiveis.contains(combustivel))
            _ItemLegenda(
              amostra: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: cores.combustivel(combustivel),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              rotulo: combustivel.rotulo,
            ),
      ],
    );
  }
}

class _ItemLegenda extends StatelessWidget {
  const _ItemLegenda({required this.amostra, required this.rotulo});

  final Widget amostra;
  final String rotulo;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        amostra,
        const SizedBox(width: 6),
        Flexible(child: Text(rotulo, style: Theme.of(context).textTheme.bodySmall)),
      ],
    );
  }
}

class _Tracejado extends CustomPainter {
  const _Tracejado(this.cor);

  final Color cor;

  @override
  void paint(Canvas canvas, Size size) {
    final pincel = Paint()
      ..color = cor
      ..strokeWidth = size.height;
    final y = size.height / 2;
    final (traco, espaco) = (tracejadoMedia[0], tracejadoMedia[1]);
    for (var x = 0.0; x < size.width; x += traco + espaco) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + traco, size.width), y), pincel);
    }
  }

  @override
  bool shouldRepaint(_Tracejado antigo) => antigo.cor != cor;
}
