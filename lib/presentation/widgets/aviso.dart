import 'package:flutter/material.dart';

const falhaAoSalvar = 'Não foi possível salvar no aparelho. Tente novamente.';

extension Aviso on ScaffoldMessengerState {
  /// Mostra [texto] no rodapé, substituindo o aviso que ainda estiver visível.
  void avisar(String texto) {
    hideCurrentSnackBar();
    showSnackBar(SnackBar(content: Text(texto)));
  }
}
