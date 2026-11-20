import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'controllers/controlador_garagem.dart';
import 'data/armazenamento_local.dart';
import 'data/cliente_brasil_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  final armazenamento = await ArmazenamentoLocal.abrir();

  runApp(App(garagem: ControladorGaragem(armazenamento), brasilApi: ClienteBrasilApi()));
}
