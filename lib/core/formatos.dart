import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

const _local = 'pt_BR';

final _moeda = NumberFormat.currency(locale: _local, symbol: r'R$');
final _precoLitro = NumberFormat.currency(locale: _local, symbol: r'R$', decimalDigits: 3);
final _inteiro = NumberFormat.decimalPattern(_local);
final _litros = NumberFormat('#,##0.0##', _local);
final _umaCasa = NumberFormat('#,##0.0', _local);
final _duasCasas = NumberFormat('#,##0.00', _local);
final _edicao = NumberFormat('0.###', _local);
final _data = DateFormat('dd/MM/yyyy', _local);
final _diaMes = DateFormat('dd/MM', _local);
final _hora = DateFormat('HH:mm', _local);
final _mesAno = DateFormat('MMMM \'de\' y', _local);
final _diaSemana = DateFormat('EEE, d MMM', _local);

String formatarMoeda(double valor) => _moeda.format(valor);

/// Preço por litro com três casas apenas quando a terceira existe (R$ 5,79 ou R$ 5,799).
String formatarPrecoLitro(double valor) {
  final texto = _precoLitro.format(valor);
  return texto.endsWith('0') ? texto.substring(0, texto.length - 1) : texto;
}

String formatarLitros(double valor) => '${_litros.format(valor)} L';

String formatarKm(int valor) => '${_inteiro.format(valor)} km';

String formatarKmPorLitro(double valor) => '${_umaCasa.format(valor)} km/L';

String formatarCustoPorKm(double valor) => 'R\$\u00a0${_duasCasas.format(valor)}/km';

String formatarCilindrada(double valor) => '${_umaCasa.format(valor)} L';

String formatarNumero(double valor, {int casas = 1}) =>
    NumberFormat.decimalPatternDigits(locale: _local, decimalDigits: casas).format(valor);

String formatarData(DateTime data) => _data.format(data);

String formatarDiaMes(DateTime data) => _diaMes.format(data);

String formatarHora(DateTime data) => _hora.format(data);

/// "Ter, 3 nov" — usado nas listas, onde o ano aparece no cabeçalho do mês.
String formatarDiaSemana(DateTime data) =>
    _capitalizar(_diaSemana.format(data).replaceAll('.', ''));

/// "Novembro de 2026".
String formatarMesAno(DateTime data) => _capitalizar(_mesAno.format(data));

/// Valor pronto para edição em um campo de texto, sem separador de milhar.
String textoParaEdicao(double valor) => _edicao.format(valor);

/// Converte o texto digitado ("5,79" ou "5.79") em número.
double? lerDecimal(String texto) => double.tryParse(texto.trim().replaceAll(',', '.'));

String _capitalizar(String texto) =>
    texto.isEmpty ? texto : texto[0].toUpperCase() + texto.substring(1);

/// Aceita só algarismos e uma vírgula, com até [casas] casas decimais. O ponto
/// digitado vira vírgula, para seguir o formato brasileiro.
class EntradaDecimal extends TextInputFormatter {
  EntradaDecimal({required int casas}) : _permitido = RegExp('^\\d*(,\\d{0,$casas})?\$');

  final RegExp _permitido;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue antigo, TextEditingValue novo) {
    final texto = novo.text.replaceAll('.', ',');
    if (!_permitido.hasMatch(texto)) return antigo;
    return novo.copyWith(text: texto);
  }
}
