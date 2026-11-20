import 'package:abastece/core/formatos.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('formata valores no padrão brasileiro', () {
    expect(formatarMoeda(1905.126), 'R\$ 1.905,13');
    expect(formatarLitros(42.6), '42,6 L');
    expect(formatarLitros(40), '40,0 L');
    expect(formatarKm(21610), '21.610 km');
    expect(formatarKmPorLitro(11.14), '11,1 km/L');
    expect(formatarCustoPorKm(0.4789), 'R\$ 0,48/km');
    expect(formatarCilindrada(1), '1,0 L');
  });

  test('preço por litro mostra a terceira casa só quando ela existe', () {
    expect(formatarPrecoLitro(5.79), 'R\$ 5,79');
    expect(formatarPrecoLitro(5.799), 'R\$ 5,799');
    expect(formatarPrecoLitro(6), 'R\$ 6,00');
  });

  test('formata datas em português', () {
    final data = DateTime(2026, 11, 7, 18, 45);

    expect(formatarData(data), '07/11/2026');
    expect(formatarHora(data), '18:45');
    expect(formatarDiaSemana(data), 'Sáb, 7 nov');
    expect(formatarMesAno(data), 'Novembro de 2026');
  });

  test('lê decimais com vírgula ou ponto', () {
    expect(lerDecimal('5,79'), 5.79);
    expect(lerDecimal(' 42.6 '), 42.6);
    expect(lerDecimal(''), isNull);
    expect(lerDecimal(','), isNull);
    expect(textoParaEdicao(42.6), '42,6');
    expect(textoParaEdicao(40), '40');
  });

  group('EntradaDecimal', () {
    final entrada = EntradaDecimal(casas: 2);

    String digitar(String antes, String depois) => entrada
        .formatEditUpdate(TextEditingValue(text: antes), TextEditingValue(text: depois))
        .text;

    test('troca o ponto por vírgula', () => expect(digitar('5', '5.'), '5,'));
    test('aceita até o limite de casas', () => expect(digitar('5,7', '5,79'), '5,79'));
    test('recusa casas além do limite', () => expect(digitar('5,79', '5,799'), '5,79'));
    test('recusa letras e uma segunda vírgula', () {
      expect(digitar('5', '5a'), '5');
      expect(digitar('5,7', '5,7,'), '5,7');
    });
  });
}
