import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/abastecimento.dart';
import '../models/veiculo.dart';

/// Guarda o veículo e seus abastecimentos em JSON no `SharedPreferences`.
///
/// Dados corrompidos são ignorados em vez de impedir a abertura do app.
class ArmazenamentoLocal {
  ArmazenamentoLocal(this._prefs);

  static const _chaveVeiculo = 'veiculo';
  static const _chaveAbastecimentos = 'abastecimentos';
  static const chaves = {_chaveVeiculo, _chaveAbastecimentos};

  final SharedPreferencesWithCache _prefs;

  static Future<ArmazenamentoLocal> abrir() async {
    final prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: chaves),
    );
    return ArmazenamentoLocal(prefs);
  }

  Veiculo? lerVeiculo() {
    try {
      return switch (_lerJson(_chaveVeiculo)) {
        final Map<String, Object?> json => Veiculo.deJson(json),
        _ => null,
      };
    } on TypeError {
      return null;
    }
  }

  Future<void> salvarVeiculo(Veiculo veiculo) =>
      _prefs.setString(_chaveVeiculo, jsonEncode(veiculo.paraJson()));

  /// Registros corrompidos são descartados um a um, sem perder os demais.
  List<Abastecimento> lerAbastecimentos() {
    final lista = _lerJson(_chaveAbastecimentos);
    if (lista is! List<Object?>) return [];
    return [for (final item in lista) ?_lerAbastecimento(item)];
  }

  static Abastecimento? _lerAbastecimento(Object? item) {
    if (item is! Map<String, Object?>) return null;
    try {
      return Abastecimento.deJson(item);
    } on TypeError {
      return null;
    } on ArgumentError {
      return null;
    } on FormatException {
      return null;
    }
  }

  Future<void> salvarAbastecimentos(List<Abastecimento> abastecimentos) => _prefs.setString(
    _chaveAbastecimentos,
    jsonEncode([for (final a in abastecimentos) a.paraJson()]),
  );

  /// Remove o veículo e todos os abastecimentos dele. Os abastecimentos saem
  /// primeiro para que uma interrupção nunca deixe registros sem veículo.
  Future<void> excluirVeiculo() async {
    await _prefs.remove(_chaveAbastecimentos);
    await _prefs.remove(_chaveVeiculo);
  }

  Object? _lerJson(String chave) {
    final texto = _prefs.getString(chave);
    if (texto == null) return null;
    try {
      return jsonDecode(texto);
    } on FormatException {
      return null;
    }
  }
}
