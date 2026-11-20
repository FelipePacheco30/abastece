import 'package:flutter/material.dart';

/// Campo com aparência de entrada de texto que abre uma tela de seleção.
class CampoSelecao extends StatelessWidget {
  const CampoSelecao({
    super.key,
    required this.rotulo,
    required this.valor,
    required this.aoTocar,
    this.dica,
    this.erro,
    this.icone = Icons.chevron_right_rounded,
  });

  final String rotulo;
  final String? valor;

  /// Nulo desabilita o campo.
  final VoidCallback? aoTocar;

  /// Texto de apoio exibido abaixo do campo enquanto não há erro.
  final String? dica;
  final String? erro;
  final IconData icone;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final habilitado = aoTocar != null;
    final valor = this.valor;

    return Semantics(
      button: true,
      enabled: habilitado,
      label: rotulo,
      value: valor ?? 'Não selecionado',
      excludeSemantics: true,
      child: InkWell(
        onTap: aoTocar,
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          isEmpty: valor == null,
          decoration: InputDecoration(
            labelText: rotulo,
            enabled: habilitado,
            helperText: dica,
            errorText: erro,
            suffixIcon: Icon(icone),
          ),
          child: valor == null
              ? null
              : Text(valor, style: tema.textTheme.bodyLarge, overflow: TextOverflow.ellipsis),
        ),
      ),
    );
  }
}
