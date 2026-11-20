import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../controllers/controlador_garagem.dart';
import '../../core/formatos.dart';
import '../../core/tema.dart';
import '../../models/abastecimento.dart';
import '../widgets/aviso.dart';
import '../widgets/campo_selecao.dart';
import '../widgets/confirmacao.dart';

/// Formulário para registrar um abastecimento ou editar um existente.
class TelaAbastecimento extends StatefulWidget {
  const TelaAbastecimento({super.key, required this.garagem, this.existente});

  final ControladorGaragem garagem;
  final Abastecimento? existente;

  static Future<void> abrir(
    BuildContext context,
    ControladorGaragem garagem, [
    Abastecimento? existente,
  ]) {
    return Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => TelaAbastecimento(garagem: garagem, existente: existente),
      ),
    );
  }

  @override
  State<TelaAbastecimento> createState() => _TelaAbastecimentoState();
}

class _TelaAbastecimentoState extends State<TelaAbastecimento> {
  final _formulario = GlobalKey<FormState>();
  late final TextEditingController _preco;
  late final TextEditingController _litros;
  late final TextEditingController _quilometragem;
  late Combustivel _combustivel;
  late DateTime _data;
  bool _validarData = false;
  bool _salvando = false;

  Abastecimento? get _existente => widget.existente;

  @override
  void initState() {
    super.initState();
    final existente = _existente;
    final ultimo = widget.garagem.historico.trechos.lastOrNull?.abastecimento;
    final agora = DateTime.now();

    _preco = TextEditingController(text: _textoInicial(existente?.precoPorLitro));
    _litros = TextEditingController(text: _textoInicial(existente?.litros));
    _quilometragem = TextEditingController(text: existente?.quilometragem.toString());
    _combustivel = existente?.combustivel ?? ultimo?.combustivel ?? Combustivel.gasolina;
    _data =
        existente?.data ?? DateTime(agora.year, agora.month, agora.day, agora.hour, agora.minute);
  }

  @override
  void dispose() {
    _preco.dispose();
    _litros.dispose();
    _quilometragem.dispose();
    super.dispose();
  }

  static String? _textoInicial(double? valor) => valor == null ? null : textoParaEdicao(valor);

  ({Abastecimento? anterior, Abastecimento? proximo}) get _vizinhos =>
      widget.garagem.historico.vizinhos(_data, ignorar: _existente?.id);

  bool get _dataNoFuturo => _data.isAfter(DateTime.now());

  Future<void> _escolherDia() async {
    final hoje = DateTime.now();
    final dia = await showDatePicker(
      context: context,
      initialDate: _data.isAfter(hoje) ? hoje : _data,
      firstDate: DateTime(1990),
      lastDate: hoje,
    );
    if (dia == null) return;
    setState(() => _data = DateTime(dia.year, dia.month, dia.day, _data.hour, _data.minute));
  }

  Future<void> _escolherHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_data),
    );
    if (horario == null) return;
    setState(
      () => _data = DateTime(_data.year, _data.month, _data.day, horario.hour, horario.minute),
    );
  }

  String? _validarPositivo(String? texto, String mensagem) {
    final valor = lerDecimal(texto ?? '');
    return valor == null || valor <= 0 ? mensagem : null;
  }

  String? _validarQuilometragem(String? texto) {
    final quilometragem = int.tryParse(texto ?? '');
    if (quilometragem == null) return 'Informe a quilometragem';

    final (:anterior, :proximo) = _vizinhos;
    if (anterior != null && quilometragem <= anterior.quilometragem) {
      return 'Deve ser maior que ${formatarKm(anterior.quilometragem)}, registrados em '
          '${formatarData(anterior.data)}';
    }
    if (proximo != null && quilometragem >= proximo.quilometragem) {
      return 'Deve ser menor que ${formatarKm(proximo.quilometragem)}, registrados em '
          '${formatarData(proximo.data)}';
    }
    return null;
  }

  Future<void> _salvar() async {
    setState(() => _validarData = true);
    if (!_formulario.currentState!.validate() || _dataNoFuturo) return;

    final mensageiro = ScaffoldMessenger.of(context);
    setState(() => _salvando = true);
    try {
      await widget.garagem.salvarAbastecimento(
        Abastecimento(
          id: _existente?.id ?? DateTime.now().microsecondsSinceEpoch.toString(),
          combustivel: _combustivel,
          precoPorLitro: lerDecimal(_preco.text)!,
          litros: lerDecimal(_litros.text)!,
          quilometragem: int.parse(_quilometragem.text),
          data: _data,
        ),
      );
    } on Exception {
      mensageiro.avisar(falhaAoSalvar);
      if (mounted) setState(() => _salvando = false);
      return;
    }
    mensageiro.avisar(_existente == null ? 'Abastecimento registrado' : 'Abastecimento atualizado');
    if (mounted) Navigator.pop(context);
  }

  Future<void> _excluir(Abastecimento existente) async {
    final confirmado = await confirmarExclusao(
      context,
      titulo: 'Excluir abastecimento?',
      mensagem:
          'O abastecimento de ${formatarData(existente.data)}, de '
          '${formatarMoeda(existente.valorTotal)}, será apagado e os indicadores serão '
          'recalculados.',
    );
    if (!confirmado || !mounted) return;

    final mensageiro = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    await widget.garagem.excluirAbastecimento(existente.id);
    mensageiro.avisar('Abastecimento excluído');
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final existente = _existente;
    final anterior = _vizinhos.anterior;

    return Scaffold(
      appBar: AppBar(
        title: Text(existente == null ? 'Novo abastecimento' : 'Editar abastecimento'),
        actions: [
          if (existente != null)
            IconButton(
              tooltip: 'Excluir abastecimento',
              onPressed: _salvando ? null : () => _excluir(existente),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: Form(
        key: _formulario,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            Text('Combustível', style: tema.textTheme.titleSmall),
            const SizedBox(height: 10),
            SegmentedButton<Combustivel>(
              segments: [
                for (final combustivel in Combustivel.values)
                  ButtonSegment(value: combustivel, label: Text(combustivel.rotulo)),
              ],
              selected: {_combustivel},
              showSelectedIcon: false,
              onSelectionChanged: _salvando
                  ? null
                  : (selecao) => setState(() => _combustivel = selecao.single),
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _CampoNumerico(
                    controlador: _preco,
                    rotulo: 'Preço por litro',
                    prefixo: r'R$ ',
                    casas: 3,
                    habilitado: !_salvando,
                    validar: (texto) => _validarPositivo(texto, 'Informe o preço'),
                    aoMudar: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _CampoNumerico(
                    controlador: _litros,
                    rotulo: 'Litros',
                    sufixo: 'L',
                    casas: 3,
                    habilitado: !_salvando,
                    validar: (texto) => _validarPositivo(texto, 'Informe os litros'),
                    aoMudar: (_) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _CampoNumerico(
              controlador: _quilometragem,
              rotulo: 'Quilometragem no hodômetro',
              sufixo: 'km',
              habilitado: !_salvando,
              dica: anterior == null
                  ? null
                  : 'Anterior: ${formatarKm(anterior.quilometragem)} em '
                        '${formatarData(anterior.data)}',
              validar: _validarQuilometragem,
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: CampoSelecao(
                    rotulo: 'Data',
                    valor: formatarData(_data),
                    icone: Icons.calendar_today_rounded,
                    aoTocar: _salvando ? null : _escolherDia,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CampoSelecao(
                    rotulo: 'Horário',
                    valor: formatarHora(_data),
                    icone: Icons.schedule_rounded,
                    aoTocar: _salvando ? null : _escolherHorario,
                    erro: _validarData && _dataNoFuturo ? 'Horário no futuro' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _ValorTotal(precoPorLitro: lerDecimal(_preco.text), litros: lerDecimal(_litros.text)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(existente == null ? 'Salvar abastecimento' : 'Salvar alterações'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoNumerico extends StatelessWidget {
  const _CampoNumerico({
    required this.controlador,
    required this.rotulo,
    required this.habilitado,
    required this.validar,
    this.casas = 0,
    this.prefixo,
    this.sufixo,
    this.dica,
    this.aoMudar,
  });

  final TextEditingController controlador;
  final String rotulo;
  final bool habilitado;
  final FormFieldValidator<String> validar;

  /// Casas decimais aceitas; zero aceita só números inteiros.
  final int casas;
  final String? prefixo;
  final String? sufixo;
  final String? dica;
  final ValueChanged<String>? aoMudar;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controlador,
      enabled: habilitado,
      decoration: InputDecoration(
        labelText: rotulo,
        prefixText: prefixo,
        suffixText: sufixo,
        helperText: dica,
      ),
      style: const TextStyle(fontFeatures: algarismosTabulares),
      keyboardType: TextInputType.numberWithOptions(decimal: casas > 0),
      textInputAction: TextInputAction.next,
      inputFormatters: casas > 0
          ? [EntradaDecimal(casas: casas)]
          : [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
      validator: validar,
      onChanged: aoMudar,
    );
  }
}

/// Valor do abastecimento calculado enquanto o usuário digita.
class _ValorTotal extends StatelessWidget {
  const _ValorTotal({required this.precoPorLitro, required this.litros});

  final double? precoPorLitro;
  final double? litros;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final cores = tema.colorScheme;
    final (preco, litros) = (precoPorLitro, this.litros);
    final completo = preco != null && litros != null;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: cores.surfaceContainer, borderRadius: raioCartao),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Valor total',
                    style: tema.textTheme.bodyMedium?.copyWith(color: cores.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    completo
                        ? '${formatarLitros(litros)} × ${formatarPrecoLitro(preco)}'
                        : 'Preço por litro × litros',
                    style: tema.textTheme.bodySmall?.copyWith(color: cores.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  formatarMoeda(completo ? Abastecimento.calcularValor(preco, litros) : 0),
                  style: tema.textTheme.headlineSmall?.copyWith(
                    fontFeatures: algarismosTabulares,
                    color: completo ? cores.onSurface : cores.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
