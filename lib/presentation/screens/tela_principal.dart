import 'package:flutter/material.dart';

import '../../controllers/controlador_garagem.dart';
import 'aba_abastecimentos.dart';
import 'aba_painel.dart';
import 'aba_veiculo.dart';
import 'tela_abastecimento.dart';

/// Tela com o veículo cadastrado, organizada em abas.
class TelaPrincipal extends StatefulWidget {
  const TelaPrincipal({super.key, required this.garagem});

  final ControladorGaragem garagem;

  @override
  State<TelaPrincipal> createState() => _TelaPrincipalState();
}

class _TelaPrincipalState extends State<TelaPrincipal> {
  var _aba = _Aba.painel;

  @override
  Widget build(BuildContext context) {
    final garagem = widget.garagem;

    return Scaffold(
      appBar: AppBar(title: Text(_aba.titulo)),
      body: switch (_aba) {
        _Aba.painel => AbaPainel(garagem: garagem),
        _Aba.abastecimentos => AbaAbastecimentos(garagem: garagem),
        _Aba.veiculo => AbaVeiculo(garagem: garagem),
      },
      floatingActionButton: _aba == _Aba.veiculo
          ? null
          : FloatingActionButton.extended(
              onPressed: () => TelaAbastecimento.abrir(context, garagem),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Abastecer'),
            ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Theme.of(context).colorScheme.outlineVariant)),
        ),
        child: NavigationBar(
          selectedIndex: _aba.index,
          onDestinationSelected: (indice) => setState(() => _aba = _Aba.values[indice]),
          destinations: [
            for (final aba in _Aba.values)
              NavigationDestination(
                icon: Icon(aba.icone),
                selectedIcon: Icon(aba.iconeSelecionado),
                label: aba.rotulo,
              ),
          ],
        ),
      ),
    );
  }
}

enum _Aba {
  painel(
    rotulo: 'Painel',
    titulo: 'Painel',
    icone: Icons.insights_outlined,
    iconeSelecionado: Icons.insights_rounded,
  ),
  abastecimentos(
    rotulo: 'Abastecimentos',
    titulo: 'Abastecimentos',
    icone: Icons.receipt_long_outlined,
    iconeSelecionado: Icons.receipt_long_rounded,
  ),
  veiculo(
    rotulo: 'Veículo',
    titulo: 'Meu veículo',
    icone: Icons.directions_car_outlined,
    iconeSelecionado: Icons.directions_car_rounded,
  );

  const _Aba({
    required this.rotulo,
    required this.titulo,
    required this.icone,
    required this.iconeSelecionado,
  });

  final String rotulo;
  final String titulo;
  final IconData icone;
  final IconData iconeSelecionado;
}
