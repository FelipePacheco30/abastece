import 'package:flutter/material.dart';

import '../../controllers/controlador_garagem.dart';
import 'aba_veiculo.dart';

class TelaPrincipal extends StatelessWidget {
  const TelaPrincipal({super.key, required this.garagem});

  final ControladorGaragem garagem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meu veículo')),
      body: AbaVeiculo(garagem: garagem),
    );
  }
}
