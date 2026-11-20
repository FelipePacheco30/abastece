import 'package:flutter/material.dart';

import '../../core/tema.dart';
import '../../models/abastecimento.dart';

/// Ícone de bomba na cor do combustível, usado como marcador nas listas.
class IconeCombustivel extends StatelessWidget {
  const IconeCombustivel(this.combustivel, {super.key});

  final Combustivel combustivel;

  @override
  Widget build(BuildContext context) {
    final cor = CoresApp.de(context).combustivel(combustivel);

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(Icons.local_gas_station_rounded, size: 20, color: cor),
    );
  }
}
