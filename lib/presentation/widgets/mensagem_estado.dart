import 'package:flutter/material.dart';

/// Estado vazio ou de erro: ícone, título, explicação e uma ação opcional.
class MensagemEstado extends StatelessWidget {
  const MensagemEstado({
    super.key,
    required this.icone,
    required this.titulo,
    required this.texto,
    this.acao,
  });

  final IconData icone;
  final String titulo;
  final String texto;
  final Widget? acao;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: cores.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icone, size: 28, color: cores.onSurfaceVariant),
            ),
            const SizedBox(height: 20),
            Text(titulo, style: tema.textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              texto,
              style: tema.textTheme.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            if (acao case final acao?) ...[const SizedBox(height: 24), acao],
          ],
        ),
      ),
    );
  }
}
