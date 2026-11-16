// The line under a list head says how current the list is, in words.
import 'package:flutter_test/flutter_test.dart';
import 'package:horizont/horizont.dart';
import 'package:landbote/app/providers.dart';
import 'package:landbote/ui/list/lage.dart';

void main() {
  final at = DateTime(2026, 11, 11, 8, 12);

  test('says nothing before the first refresh', () {
    expect(lageOf(const RefreshState()), isNull);
  });

  test('a running refresh has words, not only a spinner', () {
    final l = lageOf(RefreshState(running: true, lastAt: at))!;
    expect(l.text, 'Wird abgeglichen …');
    expect(l.status, HorizontStatus.neutral);
  });

  test('current after a clean run', () {
    final l = lageOf(RefreshState(lastAt: at))!;
    expect(l.status, HorizontStatus.positive);
    expect(l.text, contains('Aktuell'));
  });

  test('without reception it warns and says from when the list is', () {
    final l = lageOf(RefreshState(lastAt: at, offline: true, lastFailed: 2))!;
    expect(l.status, HorizontStatus.warning);
    expect(l.text, startsWith('Kein Empfang.'));
    expect(l.text, contains('Stand'));
    expect(l.text, contains('lesbar'));
  });

  test('without reception and never refreshed it still says what is going on', () {
    final l = lageOf(const RefreshState(offline: true, lastFailed: 1))!;
    expect(l.text, startsWith('Kein Empfang.'));
  });

  test('some sources failing is a warning with the count', () {
    final l = lageOf(RefreshState(lastAt: at, lastFailed: 2))!;
    expect(l.status, HorizontStatus.warning);
    expect(l.text, contains('2 Quellen nicht erreichbar.'));
  });
}
