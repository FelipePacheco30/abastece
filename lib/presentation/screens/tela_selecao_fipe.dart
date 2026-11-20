import 'package:flutter/material.dart';

import '../../data/falhas.dart';
import '../../models/opcao_fipe.dart';
import '../widgets/mensagem_estado.dart';

/// Lista pesquisável de marcas ou modelos da FIPE. Devolve a opção escolhida
/// ao fechar.
class TelaSelecaoFipe extends StatefulWidget {
  const TelaSelecaoFipe({
    super.key,
    required this.titulo,
    required this.itemNoPlural,
    required this.carregar,
    this.selecionada,
  });

  final String titulo;

  /// Nome dos itens nas mensagens ("marcas", "modelos").
  final String itemNoPlural;
  final Future<List<OpcaoFipe>> Function() carregar;
  final OpcaoFipe? selecionada;

  @override
  State<TelaSelecaoFipe> createState() => _TelaSelecaoFipeState();
}

class _TelaSelecaoFipeState extends State<TelaSelecaoFipe> {
  late Future<List<OpcaoFipe>> _opcoes = widget.carregar();
  final _busca = TextEditingController();
  List<String> _termos = const [];

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _filtrar(String texto) {
    setState(() => _termos = _normalizar(texto).split(' ')..removeWhere((t) => t.isEmpty));
  }

  bool _corresponde(OpcaoFipe opcao) {
    final nome = _normalizar(opcao.nome);
    return _termos.every(nome.contains);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.titulo)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
            child: TextField(
              controller: _busca,
              onChanged: _filtrar,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar ${widget.itemNoPlural}',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _termos.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpar busca',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _busca.clear();
                          _filtrar('');
                        },
                      ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: _opcoes,
              builder: (context, consulta) => switch (consulta) {
                AsyncSnapshot(hasError: true, :final error) => _erro(error),
                AsyncSnapshot(hasData: true, :final data?) => _lista(data),
                _ => _carregando(),
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _carregando() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text('Carregando ${widget.itemNoPlural} da tabela FIPE…'),
      ],
    );
  }

  Widget _erro(Object? erro) {
    return MensagemEstado(
      icone: Icons.cloud_off_rounded,
      titulo: 'Não foi possível carregar a lista',
      texto: erro is FalhaConsulta ? erro.mensagem : 'Ocorreu um erro inesperado.',
      acao: FilledButton.tonalIcon(
        onPressed: () => setState(() {
          _opcoes = widget.carregar();
        }),
        style: FilledButton.styleFrom(minimumSize: const Size(0, 48)),
        icon: const Icon(Icons.refresh_rounded),
        label: const Text('Tentar novamente'),
      ),
    );
  }

  Widget _lista(List<OpcaoFipe> opcoes) {
    final cores = Theme.of(context).colorScheme;
    final visiveis = _termos.isEmpty ? opcoes : opcoes.where(_corresponde).toList();

    if (visiveis.isEmpty) {
      return MensagemEstado(
        icone: Icons.search_off_rounded,
        titulo: 'Nada encontrado',
        texto:
            'Nenhuma opção corresponde a "${_busca.text.trim()}". Confira a grafia ou '
            'busque por uma parte do nome.',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            visiveis.length == 1 ? '1 resultado' : '${visiveis.length} resultados',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: cores.onSurfaceVariant),
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView.separated(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
            itemCount: visiveis.length,
            separatorBuilder: (_, _) => const Divider(indent: 20, endIndent: 20),
            itemBuilder: (context, indice) {
              final opcao = visiveis[indice];
              final selecionada = opcao == widget.selecionada;
              return ListTile(
                title: Text(opcao.nome),
                selected: selecionada,
                trailing: selecionada ? const Icon(Icons.check_rounded) : null,
                onTap: () => Navigator.pop(context, opcao),
              );
            },
          ),
        ),
      ],
    );
  }
}

const _comAcento = 'áàâãäéèêëíìîïóòôõöúùûüç';
const _semAcento = 'aaaaaeeeeiiiiooooouuuuc';

String _normalizar(String texto) {
  final minusculo = texto.toLowerCase();
  final saida = StringBuffer();
  for (final caractere in minusculo.split('')) {
    final posicao = _comAcento.indexOf(caractere);
    saida.write(posicao < 0 ? caractere : _semAcento[posicao]);
  }
  return saida.toString();
}
