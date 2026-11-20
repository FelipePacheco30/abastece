import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/controlador_garagem.dart';
import '../../core/formatos.dart';
import '../../data/cliente_brasil_api.dart';
import '../../models/opcao_fipe.dart';
import '../../models/veiculo.dart';
import '../widgets/aviso.dart';
import '../widgets/campo_selecao.dart';
import 'tela_selecao_fipe.dart';

class TelaCadastroVeiculo extends StatefulWidget {
  const TelaCadastroVeiculo({super.key, required this.garagem, required this.brasilApi});

  final ControladorGaragem garagem;
  final ClienteBrasilApi brasilApi;

  @override
  State<TelaCadastroVeiculo> createState() => _TelaCadastroVeiculoState();
}

class _TelaCadastroVeiculoState extends State<TelaCadastroVeiculo> {
  static const _anoMinimo = 1950;
  static const _cilindradaMinima = 0.5;
  static const _cilindradaMaxima = 10.0;

  final _formulario = GlobalKey<FormState>();
  final _ano = TextEditingController();
  final _cilindrada = TextEditingController();
  OpcaoFipe? _marca;
  OpcaoFipe? _modelo;
  bool _validarSelecoes = false;
  bool _salvando = false;

  int get _anoMaximo => DateTime.now().year + 1;

  @override
  void dispose() {
    _ano.dispose();
    _cilindrada.dispose();
    super.dispose();
  }

  Future<void> _escolherMarca() async {
    final marca = await _selecionar(
      titulo: 'Marca',
      itens: 'marcas',
      carregar: widget.brasilApi.buscarMarcas,
      atual: _marca,
    );
    if (marca == null || marca == _marca) return;
    setState(() {
      _marca = marca;
      _modelo = null;
    });
    _cilindrada.clear();
  }

  Future<void> _escolherModelo() async {
    final modelo = await _selecionar(
      titulo: 'Modelo',
      itens: 'modelos',
      carregar: () => widget.brasilApi.buscarModelos(_marca!.codigo),
      atual: _modelo,
    );
    if (modelo == null) return;
    setState(() => _modelo = modelo);
    final cilindrada = Veiculo.cilindradaDoModelo(modelo.nome);
    _cilindrada.text = cilindrada == null ? '' : textoParaEdicao(cilindrada);
  }

  Future<OpcaoFipe?> _selecionar({
    required String titulo,
    required String itens,
    required Future<List<OpcaoFipe>> Function() carregar,
    required OpcaoFipe? atual,
  }) {
    return Navigator.push<OpcaoFipe>(
      context,
      MaterialPageRoute(
        builder: (_) => TelaSelecaoFipe(
          titulo: titulo,
          itemNoPlural: itens,
          carregar: carregar,
          selecionada: atual,
        ),
      ),
    );
  }

  String? _validarAno(String? texto) {
    final ano = int.tryParse(texto ?? '');
    if (ano == null) return 'Informe o ano';
    if (ano < _anoMinimo || ano > _anoMaximo) {
      return 'Informe um ano entre $_anoMinimo e $_anoMaximo';
    }
    return null;
  }

  String? _validarCilindrada(String? texto) {
    final cilindrada = lerDecimal(texto ?? '');
    if (cilindrada == null) return 'Informe a cilindrada';
    if (cilindrada < _cilindradaMinima || cilindrada > _cilindradaMaxima) {
      return 'Use um valor entre ${formatarNumero(_cilindradaMinima)} e '
          '${formatarNumero(_cilindradaMaxima)}';
    }
    return null;
  }

  Future<void> _salvar() async {
    setState(() => _validarSelecoes = true);
    final camposValidos = _formulario.currentState!.validate();
    final (marca, modelo) = (_marca, _modelo);
    if (!camposValidos || marca == null || modelo == null) return;

    final mensageiro = ScaffoldMessenger.of(context);
    setState(() => _salvando = true);
    try {
      await widget.garagem.cadastrarVeiculo(
        Veiculo(
          marca: marca.nome,
          modelo: modelo.nome,
          ano: int.parse(_ano.text),
          cilindrada: lerDecimal(_cilindrada.text)!,
        ),
      );
    } on Exception {
      mensageiro.avisar(falhaAoSalvar);
      if (mounted) setState(() => _salvando = false);
      return;
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final marca = _marca;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastrar veículo')),
      body: Form(
        key: _formulario,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text(
              'Marca e modelo vêm da tabela FIPE. Ano e cilindrada ficam a seu critério.',
              style: tema.textTheme.bodyMedium?.copyWith(color: tema.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            CampoSelecao(
              rotulo: 'Marca',
              valor: marca?.nome,
              aoTocar: _salvando ? null : _escolherMarca,
              erro: _validarSelecoes && marca == null ? 'Escolha a marca' : null,
            ),
            const SizedBox(height: 16),
            CampoSelecao(
              rotulo: 'Modelo',
              valor: _modelo?.nome,
              aoTocar: marca == null || _salvando ? null : _escolherModelo,
              dica: marca == null ? 'Escolha a marca primeiro' : null,
              erro: _validarSelecoes && marca != null && _modelo == null
                  ? 'Escolha o modelo'
                  : null,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ano,
                    enabled: !_salvando,
                    decoration: const InputDecoration(labelText: 'Ano', hintText: 'Ex.: 2022'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    validator: _validarAno,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cilindrada,
                    enabled: !_salvando,
                    decoration: const InputDecoration(
                      labelText: 'Cilindrada',
                      hintText: 'Ex.: 1,6',
                      suffixText: 'L',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    textInputAction: TextInputAction.done,
                    inputFormatters: [EntradaDecimal(casas: 1)],
                    validator: _validarCilindrada,
                    onFieldSubmitted: (_) => _salvar(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: const Text('Salvar veículo'),
            ),
          ],
        ),
      ),
    );
  }
}
