class Veiculo {
  const Veiculo({
    required this.marca,
    required this.modelo,
    required this.ano,
    required this.cilindrada,
  });

  factory Veiculo.deJson(Map<String, Object?> json) => Veiculo(
    marca: json['marca'] as String,
    modelo: json['modelo'] as String,
    ano: json['ano'] as int,
    cilindrada: (json['cilindrada'] as num).toDouble(),
  );

  final String marca;
  final String modelo;
  final int ano;

  /// Em litros, como nos nomes dos modelos da FIPE (1.0, 1.6, 2.0).
  final double cilindrada;

  Map<String, Object?> paraJson() => {
    'marca': marca,
    'modelo': modelo,
    'ano': ano,
    'cilindrada': cilindrada,
  };

  static final _padraoCilindrada = RegExp(r'(?<!\d)(\d)[.,](\d)(?!\d)');

  /// Cilindrada informada no nome do modelo da FIPE, como em
  /// "ARGO DRIVE 1.3 8V Flex" → 1.3. Nula quando o nome não a informa.
  static double? cilindradaDoModelo(String modelo) {
    final encontrada = _padraoCilindrada.firstMatch(modelo);
    if (encontrada == null) return null;
    return double.parse('${encontrada[1]}.${encontrada[2]}');
  }
}
