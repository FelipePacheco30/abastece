import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/controlador_garagem.dart';
import 'core/tema.dart';
import 'data/cliente_brasil_api.dart';
import 'presentation/screens/tela_boas_vindas.dart';
import 'presentation/screens/tela_principal.dart';

class App extends StatelessWidget {
  const App({super.key, required this.garagem, required this.brasilApi});

  final ControladorGaragem garagem;
  final ClienteBrasilApi brasilApi;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Abastece',
      debugShowCheckedModeBanner: false,
      theme: criarTema(Brightness.light),
      darkTheme: criarTema(Brightness.dark),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: ListenableBuilder(
        listenable: garagem,
        builder: (context, _) => garagem.veiculo == null
            ? TelaBoasVindas(garagem: garagem, brasilApi: brasilApi)
            : TelaPrincipal(garagem: garagem),
      ),
    );
  }
}
