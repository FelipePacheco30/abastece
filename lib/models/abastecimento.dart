enum Combustivel {
  etanol('Etanol'),
  gasolina('Gasolina'),
  diesel('Diesel');

  const Combustivel(this.rotulo);

  final String rotulo;
}

class Abastecimento {
  const Abastecimento({
    required this.id,
    required this.combustivel,
    required this.precoPorLitro,
    required this.litros,
    required this.quilometragem,
    required this.data,
  });

  factory Abastecimento.deJson(Map<String, Object?> json) => Abastecimento(
    id: json['id'] as String,
    combustivel: Combustivel.values.byName(json['combustivel'] as String),
    precoPorLitro: (json['precoPorLitro'] as num).toDouble(),
    litros: (json['litros'] as num).toDouble(),
    quilometragem: json['quilometragem'] as int,
    data: DateTime.parse(json['data'] as String),
  );

  final String id;
  final Combustivel combustivel;
  final double precoPorLitro;
  final double litros;

  /// Leitura do hodômetro, em km, no momento do abastecimento.
  final int quilometragem;
  final DateTime data;

  double get valorTotal => precoPorLitro * litros;

  Map<String, Object?> paraJson() => {
    'id': id,
    'combustivel': combustivel.name,
    'precoPorLitro': precoPorLitro,
    'litros': litros,
    'quilometragem': quilometragem,
    'data': data.toIso8601String(),
  };

  /// Ordem cronológica; no mesmo horário, a menor quilometragem vem antes.
  static int comparar(Abastecimento a, Abastecimento b) {
    final porData = a.data.compareTo(b.data);
    return porData != 0 ? porData : a.quilometragem.compareTo(b.quilometragem);
  }
}
