import 'abastecimento.dart';

/// Um abastecimento e os indicadores do trecho rodado desde o anterior.
class Trecho {
  const Trecho(this.abastecimento, {this.distancia});

  final Abastecimento abastecimento;

  /// Quilômetros rodados desde o abastecimento anterior. É nula no primeiro
  /// abastecimento, que serve apenas de referência.
  final int? distancia;

  bool get temIndicadores => distancia != null;

  double? get kmPorLitro => switch (distancia) {
    final d? => d / abastecimento.litros,
    null => null,
  };

  double? get custoPorKm => switch (distancia) {
    final d? => abastecimento.valorTotal / d,
    null => null,
  };
}

/// Abastecimentos em ordem cronológica com os indicadores de cada trecho.
///
/// Todos os registros são tratados como tanque cheio: o combustível colocado
/// em um abastecimento repõe o que foi gasto desde o anterior.
class Historico {
  Historico(Iterable<Abastecimento> abastecimentos) : trechos = _calcularTrechos(abastecimentos);

  final List<Trecho> trechos;

  static List<Trecho> _calcularTrechos(Iterable<Abastecimento> abastecimentos) {
    final ordenados = abastecimentos.toList()..sort(Abastecimento.comparar);
    return [
      for (var i = 0; i < ordenados.length; i++)
        Trecho(
          ordenados[i],
          distancia: i == 0 ? null : ordenados[i].quilometragem - ordenados[i - 1].quilometragem,
        ),
    ];
  }

  bool get vazio => trechos.isEmpty;

  List<Abastecimento> get abastecimentos => [for (final t in trechos) t.abastecimento];

  Iterable<Trecho> get comIndicadores => trechos.where((t) => t.temIndicadores);

  double get gastoTotal => trechos.fold(0, (soma, t) => soma + t.abastecimento.valorTotal);

  int get distanciaTotal => comIndicadores.fold(0, (soma, t) => soma + t.distancia!);

  /// Média ponderada pela distância: total rodado dividido pelos litros que
  /// repuseram esse trecho (o primeiro abastecimento não entra na conta).
  double? get consumoMedio {
    if (distanciaTotal == 0) return null;
    return distanciaTotal / comIndicadores.fold(0.0, (soma, t) => soma + t.abastecimento.litros);
  }

  double? get custoMedioPorKm {
    if (distanciaTotal == 0) return null;
    return comIndicadores.fold(0.0, (soma, t) => soma + t.abastecimento.valorTotal) /
        distanciaTotal;
  }

  /// Abastecimentos imediatamente antes e depois de [data], que limitam a
  /// quilometragem aceita para um registro nesse momento. [ignorar] exclui da
  /// busca o registro que está sendo editado.
  ({Abastecimento? anterior, Abastecimento? proximo}) vizinhos(DateTime data, {String? ignorar}) {
    Abastecimento? anterior;
    for (final trecho in trechos) {
      final abastecimento = trecho.abastecimento;
      if (abastecimento.id == ignorar) continue;
      if (abastecimento.data.isAfter(data)) return (anterior: anterior, proximo: abastecimento);
      anterior = abastecimento;
    }
    return (anterior: anterior, proximo: null);
  }
}
