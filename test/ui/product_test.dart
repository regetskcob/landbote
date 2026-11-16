import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/horizont.dart';
import 'package:horizont/testing.dart';
import 'package:landbote/theme/product.dart';

Color _hex(Object? v) =>
    Color(int.parse('FF${(v! as String).substring(1)}', radix: 16));

void main() {
  final json = jsonDecode(
    File('tool/horizont/horizont.product.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  test('the product holds the guard rails of Horizont', () {
    expectProductHoldsContrast(landbote);
  });

  test('product.dart and horizont.product.json say the same', () {
    expect(landbote.displayName, json['name']);
    expect(landbote.accentName, json['accentName']);
    for (final (mode, accent) in [
      ('light', landbote.light),
      ('dark', landbote.dark),
    ]) {
      final m = json[mode] as Map<String, dynamic>;
      expect(accent.accent, _hex(m['accent']), reason: '$mode accent');
      expect(accent.onAccent, _hex(m['on-accent']), reason: '$mode on-accent');
      expect(
        accent.accentTint,
        _hex(m['accent-tint']),
        reason: '$mode accent-tint',
      );
      expect(
        accent.accentText,
        _hex(m['accent-text']),
        reason: '$mode accent-text',
      );
    }
    expect(landbote.neutralDark, isNull);
    expect(json.containsKey('neutralDark'), isFalse);
    expect(landbote.softLight, isNull);
    expect(json.containsKey('soft'), isFalse);
  });

  testWidgets('the mark draws the glyph', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: HorizontMark(
            landbote,
            size: 48,
            color: const Color(0xFF000000),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(landbote.mark, isNotNull);
    expect(find.bySemanticsLabel('Landbote'), findsOneWidget);
  });
}
