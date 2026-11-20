import 'package:abastece/app.dart';
import 'package:abastece/controllers/controlador_garagem.dart';
import 'package:abastece/data/cliente_brasil_api.dart';
import 'package:abastece/models/abastecimento.dart';
import 'package:abastece/models/veiculo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'armazenamento_em_memoria.dart';
import 'fixtures.dart';

/// Abre o app completo com o [veiculo] e os [abastecimentos] já gravados no
/// aparelho e a BrasilAPI simulada por [servico] (respostas gravadas por padrão).
Future<ControladorGaragem> abrirApp(
  WidgetTester tester, {
  Veiculo? veiculo,
  List<Abastecimento> abastecimentos = const [],
  http.Client? servico,
}) async {
  final armazenamento = await armazenamentoEmMemoria();
  if (veiculo != null) await armazenamento.salvarVeiculo(veiculo);
  await armazenamento.salvarAbastecimentos(abastecimentos);

  final garagem = ControladorGaragem(armazenamento);
  await tester.pumpWidget(
    App(
      garagem: garagem,
      brasilApi: ClienteBrasilApi(cliente: servico ?? brasilApiFalsa()),
    ),
  );
  await tester.pumpAndSettle();
  return garagem;
}
