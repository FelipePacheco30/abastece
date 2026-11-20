import 'package:flutter/material.dart';

import '../../controllers/controlador_garagem.dart';
import '../../data/cliente_brasil_api.dart';
import 'tela_cadastro_veiculo.dart';

/// Primeira tela, exibida enquanto não há veículo cadastrado.
class TelaBoasVindas extends StatelessWidget {
  const TelaBoasVindas({super.key, required this.garagem, required this.brasilApi});

  final ControladorGaragem garagem;
  final ClienteBrasilApi brasilApi;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, limites) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: limites.maxHeight - 56),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: cores.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        Icons.local_gas_station_rounded,
                        color: cores.onPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Saiba quanto seu carro gasta de verdade',
                      style: tema.textTheme.headlineMedium?.copyWith(height: 1.2),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Registre cada abastecimento e acompanhe o consumo em km/L e o custo por '
                      'quilômetro rodado.',
                      style: tema.textTheme.bodyLarge?.copyWith(color: cores.onSurfaceVariant),
                    ),
                    const SizedBox(height: 32),
                    const _Destaque(
                      icone: Icons.directions_car_outlined,
                      texto: 'Marcas e modelos da tabela FIPE',
                    ),
                    const _Destaque(
                      icone: Icons.insights_rounded,
                      texto: 'Gráficos de consumo e de custo',
                    ),
                    const _Destaque(
                      icone: Icons.phone_android_rounded,
                      texto: 'Dados guardados no seu aparelho',
                    ),
                    const Spacer(flex: 2),
                    const SizedBox(height: 32),
                    FilledButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              TelaCadastroVeiculo(garagem: garagem, brasilApi: brasilApi),
                        ),
                      ),
                      child: const Text('Cadastrar veículo'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Destaque extends StatelessWidget {
  const _Destaque({required this.icone, required this.texto});

  final IconData icone;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icone, size: 22, color: tema.colorScheme.primary),
          const SizedBox(width: 14),
          Expanded(child: Text(texto, style: tema.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
