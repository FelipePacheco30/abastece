import 'package:flutter/material.dart';

import '../models/abastecimento.dart';

/// Cores com significado no app, fora do esquema padrão do Material.
@immutable
class CoresApp extends ThemeExtension<CoresApp> {
  const CoresApp({
    required this.etanol,
    required this.gasolina,
    required this.diesel,
    required this.consumo,
    required this.custo,
  });

  final Color etanol;
  final Color gasolina;
  final Color diesel;

  /// Séries de km/L e de R$/km nos gráficos.
  final Color consumo;
  final Color custo;

  static CoresApp de(BuildContext context) => Theme.of(context).extension<CoresApp>()!;

  Color combustivel(Combustivel combustivel) => switch (combustivel) {
    Combustivel.etanol => etanol,
    Combustivel.gasolina => gasolina,
    Combustivel.diesel => diesel,
  };

  @override
  CoresApp copyWith({
    Color? etanol,
    Color? gasolina,
    Color? diesel,
    Color? consumo,
    Color? custo,
  }) => CoresApp(
    etanol: etanol ?? this.etanol,
    gasolina: gasolina ?? this.gasolina,
    diesel: diesel ?? this.diesel,
    consumo: consumo ?? this.consumo,
    custo: custo ?? this.custo,
  );

  @override
  CoresApp lerp(CoresApp? other, double t) {
    if (other == null) return this;
    return CoresApp(
      etanol: Color.lerp(etanol, other.etanol, t)!,
      gasolina: Color.lerp(gasolina, other.gasolina, t)!,
      diesel: Color.lerp(diesel, other.diesel, t)!,
      consumo: Color.lerp(consumo, other.consumo, t)!,
      custo: Color.lerp(custo, other.custo, t)!,
    );
  }
}

const raioCartao = BorderRadius.all(Radius.circular(16));
const _raioControle = BorderRadius.all(Radius.circular(12));

/// Números alinhados em colunas, para valores que mudam ou ficam empilhados.
const algarismosTabulares = [FontFeature.tabularFigures()];

ThemeData criarTema(Brightness brilho) {
  final escuro = brilho == Brightness.dark;
  final esquema = ColorScheme(
    brightness: brilho,
    primary: escuro ? const Color(0xFF4FC9B9) : const Color(0xFF0F766E),
    onPrimary: escuro ? const Color(0xFF03211E) : Colors.white,
    primaryContainer: escuro ? const Color(0xFF133631) : const Color(0xFFD6F1ED),
    onPrimaryContainer: escuro ? const Color(0xFFA9EDE3) : const Color(0xFF0A4D48),
    secondary: escuro ? const Color(0xFFA3ACB7) : const Color(0xFF4B5563),
    onSecondary: escuro ? const Color(0xFF111418) : Colors.white,
    tertiary: escuro ? const Color(0xFFFB923C) : const Color(0xFFC2410C),
    onTertiary: escuro ? const Color(0xFF2B1300) : Colors.white,
    error: escuro ? const Color(0xFFF97066) : const Color(0xFFB42318),
    onError: escuro ? const Color(0xFF3A0B07) : Colors.white,
    errorContainer: escuro ? const Color(0xFF3B1714) : const Color(0xFFFDECEA),
    onErrorContainer: escuro ? const Color(0xFFFECDCA) : const Color(0xFF7A1A12),
    surface: escuro ? const Color(0xFF0F1113) : const Color(0xFFF5F6F8),
    onSurface: escuro ? const Color(0xFFE7E9EC) : const Color(0xFF14171C),
    onSurfaceVariant: escuro ? const Color(0xFF9AA3AE) : const Color(0xFF5B6370),
    surfaceContainerLowest: escuro ? const Color(0xFF171A1D) : Colors.white,
    surfaceContainerLow: escuro ? const Color(0xFF1A1D21) : const Color(0xFFFAFAFB),
    surfaceContainer: escuro ? const Color(0xFF1E2226) : const Color(0xFFEEF0F3),
    surfaceContainerHigh: escuro ? const Color(0xFF252A2F) : const Color(0xFFE6E9ED),
    surfaceContainerHighest: escuro ? const Color(0xFF2C3238) : const Color(0xFFDEE2E7),
    outline: escuro ? const Color(0xFF3B424A) : const Color(0xFFCBD1D8),
    outlineVariant: escuro ? const Color(0xFF262B31) : const Color(0xFFE3E6EA),
    inverseSurface: escuro ? const Color(0xFFE7E9EC) : const Color(0xFF1C2025),
    onInverseSurface: escuro ? const Color(0xFF14171C) : const Color(0xFFF0F2F4),
  );

  final base = ThemeData(colorScheme: esquema, fontFamily: 'Inter');
  final textos = _tipografia(base.textTheme);
  OutlineInputBorder borda(Color cor, [double largura = 1]) => OutlineInputBorder(
    borderRadius: _raioControle,
    borderSide: BorderSide(color: cor, width: largura),
  );

  return base.copyWith(
    scaffoldBackgroundColor: esquema.surface,
    extensions: [
      CoresApp(
        etanol: escuro ? const Color(0xFF4ADE80) : const Color(0xFF15803D),
        gasolina: escuro ? const Color(0xFFF87171) : const Color(0xFFC81E1E),
        diesel: escuro ? const Color(0xFF60A5FA) : const Color(0xFF1D4ED8),
        consumo: esquema.primary,
        custo: esquema.tertiary,
      ),
    ],
    textTheme: textos,
    appBarTheme: AppBarTheme(
      backgroundColor: esquema.surface,
      foregroundColor: esquema.onSurface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textos.titleLarge?.copyWith(fontSize: 20, color: esquema.onSurface),
    ),
    cardTheme: CardThemeData(
      color: esquema.surfaceContainerLowest,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: raioCartao,
        side: BorderSide(color: esquema.outlineVariant),
      ),
    ),
    dividerTheme: DividerThemeData(color: esquema.outlineVariant, space: 1, thickness: 1),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: esquema.surfaceContainerLowest,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: borda(esquema.outline),
      enabledBorder: borda(esquema.outline),
      disabledBorder: borda(esquema.outlineVariant),
      focusedBorder: borda(esquema.primary, 2),
      errorBorder: borda(esquema.error),
      focusedErrorBorder: borda(esquema.error, 2),
      helperMaxLines: 2,
      errorMaxLines: 2,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(borderRadius: _raioControle),
        textStyle: textos.labelLarge?.copyWith(fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: const RoundedRectangleBorder(borderRadius: _raioControle),
        side: BorderSide(color: esquema.outline),
        textStyle: textos.labelLarge?.copyWith(fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(textStyle: textos.labelLarge)),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        backgroundColor: esquema.surfaceContainerLowest,
        foregroundColor: esquema.onSurface,
        selectedBackgroundColor: esquema.primaryContainer,
        selectedForegroundColor: esquema.onPrimaryContainer,
        side: BorderSide(color: esquema.outline),
        shape: const RoundedRectangleBorder(borderRadius: _raioControle),
        textStyle: textos.labelLarge,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: esquema.primary,
      foregroundColor: esquema.onPrimary,
      elevation: 2,
      focusElevation: 2,
      hoverElevation: 3,
      highlightElevation: 3,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      extendedTextStyle: textos.labelLarge?.copyWith(fontSize: 15),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: esquema.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
      indicatorColor: esquema.primaryContainer,
      elevation: 0,
      height: 72,
      labelTextStyle: WidgetStateProperty.resolveWith(
        (estados) => textos.labelMedium?.copyWith(
          fontWeight: estados.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w500,
          color: estados.contains(WidgetState.selected)
              ? esquema.onSurface
              : esquema.onSurfaceVariant,
        ),
      ),
      iconTheme: WidgetStateProperty.resolveWith(
        (estados) => IconThemeData(
          color: estados.contains(WidgetState.selected)
              ? esquema.onPrimaryContainer
              : esquema.onSurfaceVariant,
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      iconColor: esquema.onSurfaceVariant,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: esquema.surfaceContainerLowest,
      titleTextStyle: textos.titleLarge?.copyWith(color: esquema.onSurface),
      contentTextStyle: textos.bodyMedium?.copyWith(color: esquema.onSurfaceVariant),
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: esquema.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
    ),
    timePickerTheme: TimePickerThemeData(backgroundColor: esquema.surfaceContainerLowest),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: esquema.surfaceContainerLowest,
      surfaceTintColor: Colors.transparent,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: _raioControle),
      backgroundColor: esquema.inverseSurface,
      contentTextStyle: textos.bodyMedium?.copyWith(color: esquema.onInverseSurface),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: esquema.primary,
      linearTrackColor: esquema.primaryContainer,
    ),
  );
}

/// Pesos e espaçamento ajustados para a Inter, que já é espaçada: o
/// espaçamento extra do Material 3 a deixa dispersa.
TextTheme _tipografia(TextTheme textos) => textos.copyWith(
  headlineMedium: textos.headlineMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.5),
  headlineSmall: textos.headlineSmall?.copyWith(
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    height: 1.25,
  ),
  titleLarge: textos.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.2),
  titleMedium: textos.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: -0.1),
  titleSmall: textos.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
  bodyLarge: textos.bodyLarge?.copyWith(letterSpacing: 0, height: 1.45),
  bodyMedium: textos.bodyMedium?.copyWith(letterSpacing: 0, height: 1.45),
  bodySmall: textos.bodySmall?.copyWith(letterSpacing: 0),
  labelLarge: textos.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
  labelMedium: textos.labelMedium?.copyWith(letterSpacing: 0),
  labelSmall: textos.labelSmall?.copyWith(letterSpacing: 0.1),
);
