/// Falhas ao consultar a BrasilAPI, com a mensagem exibida ao usuário.
sealed class FalhaConsulta implements Exception {
  const FalhaConsulta(this.mensagem);

  final String mensagem;

  @override
  String toString() => '$runtimeType: $mensagem';
}

final class FalhaConexao extends FalhaConsulta {
  const FalhaConexao() : super('Sem conexão com a internet. Verifique a rede e tente novamente.');
}

final class ServicoIndisponivel extends FalhaConsulta {
  const ServicoIndisponivel()
    : super('A BrasilAPI está indisponível no momento. Tente novamente em instantes.');
}

final class RespostaInvalida extends FalhaConsulta {
  const RespostaInvalida() : super('A BrasilAPI respondeu em um formato inesperado.');
}
