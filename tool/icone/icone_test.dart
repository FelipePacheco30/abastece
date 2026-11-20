// Gera os ícones do app para Android e iOS a partir do ícone de bomba de
// combustível do Material, na cor primária do tema.
//
//   flutter test tool/icone --update-goldens
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

const _fundo = Color(0xFF0F766E);
const _res = '../../android/app/src/main/res';
const _ios = '../../ios/Runner/Assets.xcassets/AppIcon.appiconset';

/// Densidades do Android: ícone tradicional de 48 dp e camada adaptativa de 108 dp.
const _densidades = {'mdpi': 1.0, 'hdpi': 1.5, 'xhdpi': 2.0, 'xxhdpi': 3.0, 'xxxhdpi': 4.0};

const _tamanhosIos = {
  'Icon-App-20x20@1x': 20,
  'Icon-App-20x20@2x': 40,
  'Icon-App-20x20@3x': 60,
  'Icon-App-29x29@1x': 29,
  'Icon-App-29x29@2x': 58,
  'Icon-App-29x29@3x': 87,
  'Icon-App-40x40@1x': 40,
  'Icon-App-40x40@2x': 80,
  'Icon-App-40x40@3x': 120,
  'Icon-App-60x60@2x': 120,
  'Icon-App-60x60@3x': 180,
  'Icon-App-76x76@1x': 76,
  'Icon-App-76x76@2x': 152,
  'Icon-App-83.5x83.5@2x': 167,
  'Icon-App-1024x1024@1x': 1024,
};

void main() {
  setUpAll(() async {
    final flutter =
        Platform.environment['FLUTTER_ROOT'] ??
        File(Platform.resolvedExecutable).parent.parent.parent.parent.parent.parent.path;
    final fonte = File('$flutter/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
    await (FontLoader(
      'MaterialIcons',
    )..addFont(Future.value(ByteData.sublistView(fonte.readAsBytesSync())))).load();
  });

  for (final MapEntry(key: densidade, value: escala) in _densidades.entries) {
    testWidgets('android $densidade', (tester) async {
      await _gerar(tester, 48 * escala, '$_res/mipmap-$densidade/ic_launcher.png');
      await _gerar(
        tester,
        108 * escala,
        '$_res/mipmap-$densidade/ic_launcher_foreground.png',
        comFundo: false,
        proporcaoGlifo: 0.4,
      );
    });
  }

  for (final MapEntry(key: nome, value: tamanho) in _tamanhosIos.entries) {
    testWidgets('ios $nome', (tester) => _gerar(tester, tamanho.toDouble(), '$_ios/$nome.png'));
  }
}

Future<void> _gerar(
  WidgetTester tester,
  double tamanho,
  String destino, {
  bool comFundo = true,
  double proporcaoGlifo = 0.58,
}) async {
  tester.view.physicalSize = Size.square(tamanho);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    RepaintBoundary(
      child: ColoredBox(
        color: comFundo ? _fundo : Colors.transparent,
        child: Center(
          child: Icon(
            Icons.local_gas_station_rounded,
            size: tamanho * proporcaoGlifo,
            color: Colors.white,
            textDirection: TextDirection.ltr,
          ),
        ),
      ),
    ),
  );
  await expectLater(find.byType(RepaintBoundary).first, matchesGoldenFile(destino));
}
