import 'package:flutter/material.dart';

extension Aviso on ScaffoldMessengerState {
  /// Mostra [texto] no rodapé, substituindo o aviso que ainda estiver visível.
  void avisar(String texto) {
    hideCurrentSnackBar();
    showSnackBar(SnackBar(content: Text(texto)));
  }
}
