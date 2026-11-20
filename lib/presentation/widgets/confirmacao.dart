import 'package:flutter/material.dart';

/// Pede confirmação antes de apagar algo. Devolve `true` só se o usuário
/// tocar em "Excluir".
Future<bool> confirmarExclusao(
  BuildContext context, {
  required String titulo,
  required String mensagem,
}) async {
  final confirmado = await showDialog<bool>(
    context: context,
    builder: (context) {
      final cores = Theme.of(context).colorScheme;
      return AlertDialog(
        icon: Icon(Icons.delete_outline_rounded, color: cores.error),
        title: Text(titulo),
        content: Text('$mensagem Essa ação não pode ser desfeita.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: cores.error,
              foregroundColor: cores.onError,
              minimumSize: const Size(64, 40),
            ),
            child: const Text('Excluir'),
          ),
        ],
      );
    },
  );
  return confirmado ?? false;
}
