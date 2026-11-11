/// Small building blocks of the settings pages.
library;

import 'package:flutter/material.dart';
import 'package:horizont/horizont.dart';

import '../../l10n/strings.dart';

/// A settings page: Kennung head, content in the form width.
class SettingsScaffold extends StatelessWidget {
  /// Creates the page.
  const SettingsScaffold({required this.kennung, required this.title, required this.children, super.key});

  /// The Kennung.
  final String kennung;

  /// The title.
  final String title;

  /// The rows.
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          toolbarHeight: HorizontTitle.toolbarHeight(context),
          title: HorizontTitle(kennung: kennung, title: title),
        ),
        body: ListView(
          padding: const EdgeInsets.only(bottom: HzSpace.s48),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: HzSize.textColumn),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
              ),
            ),
          ],
        ),
      );
}

/// A row that leads to another page.
class NavRow extends StatelessWidget {
  /// Creates the row.
  const NavRow({required this.title, required this.onTap, this.icon, this.value, this.locked = false, super.key});

  /// The label.
  final String title;

  /// A symbol in front.
  final IconData? icon;

  /// The current value, muted, at the end.
  final String? value;

  /// Shows "Im Förderpaket" instead of the value.
  final bool locked;

  /// Opens the page.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = HorizontTheme.of(context).colors;
    final t = Theme.of(context).textTheme;
    return _Line(
      child: ListTile(
        leading: icon == null ? null : Icon(icon, size: HzIconSize.row, color: c.text),
        title: Text(title),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          if (locked)
            Text(S.locked, style: t.bodySmall?.copyWith(color: c.accentText))
          else if (value != null)
            Text(value!, style: t.bodyMedium?.copyWith(color: c.textMuted)),
          const SizedBox(width: HzSpace.s4),
          Icon(HorizontSymbols.chevronRight, size: HzIconSize.row, color: c.textMuted),
        ]),
        onTap: onTap,
      ),
    );
  }
}

/// A row with a choice from a few fixed values.
class ChoiceRow<T> extends StatelessWidget {
  /// Creates the row.
  const ChoiceRow({required this.title, required this.value, required this.items, required this.onChanged, this.help, this.icon, super.key});

  /// The label.
  final String title;

  /// A line below.
  final String? help;

  /// A symbol in front.
  final IconData? icon;

  /// The value.
  final T value;

  /// The values with their words.
  final List<(T, String)> items;

  /// Called with the new value.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => _Line(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(HzSpace.s16, HzSpace.s12, HzSpace.s16, HzSpace.s16),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: HzSize.form),
              // Horizont's form: the label above the field, help below.
              child: HorizontField(
                label: title,
                help: help,
                child: HorizontFieldDropdown<T>(value: value, items: items, onChanged: onChanged),
              ),
            ),
          ),
        ),
      );
}

/// A switch row.
class SwitchRow extends StatelessWidget {
  /// Creates the row.
  const SwitchRow({required this.title, required this.value, required this.onChanged, this.help, super.key});

  /// The label.
  final String title;

  /// A line below.
  final String? help;

  /// The value.
  final bool value;

  /// Called with the new value.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => _Line(
        child: SwitchListTile.adaptive(
          title: Text(title),
          subtitle: help == null ? null : Text(help!, style: Theme.of(context).textTheme.bodySmall),
          value: value,
          onChanged: onChanged,
        ),
      );
}

/// A section's Kennung.
class SectionKennung extends StatelessWidget {
  /// Creates it.
  const SectionKennung(this.text, {super.key});

  /// The text.
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(HzSpace.s16, HzSpace.s32, HzSpace.s16, HzSpace.s8),
        child: Semantics(header: true, child: Kennung(text)),
      );
}

class _Line extends StatelessWidget {
  const _Line({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(border: Border(bottom: BorderSide(color: HorizontTheme.of(context).colors.line, width: HzLine.hairline))),
        child: child,
      );
}
