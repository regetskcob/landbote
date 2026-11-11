/// Lesestil (Förderpaket): font, size, spacing, alignment, with a preview.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';

import '../../app/settings.dart';
import '../../app/supporter.dart';
import '../../l10n/strings.dart';
import '../reader/article_html.dart';
import 'supporter_page.dart';
import 'widgets.dart';

/// The page.
class ReadingStylePage extends ConsumerWidget {
  /// Creates the page.
  const ReadingStylePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supporter = ref.watch(isSupporterProvider);
    if (!supporter) return const SupporterPage();
    final s = ref.watch(settingsProvider);
    final set = ref.read(settingsProvider.notifier).update;
    final style = ReaderStyle.of(context, s, supporter: true);
    final c = HorizontTheme.of(context).colors;
    return SettingsScaffold(kennung: S.supporterTitle, title: S.readingStyle, children: [
      Container(
        margin: const EdgeInsets.all(HzSpace.s16),
        padding: const EdgeInsets.all(HzSpace.s16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(HzSoft.card),
          border: Border.all(color: c.line, width: HzLine.hairline),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Kennung(S.preview),
          const SizedBox(height: HzSpace.s8),
          Text(S.previewText, style: style.body, textAlign: style.justify ? TextAlign.justify : TextAlign.start),
        ]),
      ),
      ChoiceRow<ReaderFont>(
        title: S.font,
        value: s.readerFont,
        items: const [(ReaderFont.literata, S.fontLiterata), (ReaderFont.mona, S.fontMona)],
        onChanged: (v) => set((x) => x.copyWith(readerFont: v)),
      ),
      ChoiceRow<double>(
        title: S.size,
        value: s.readerScale,
        items: const [(0.9, '90 %'), (1.0, '100 %'), (1.15, '115 %'), (1.3, '130 %')],
        onChanged: (v) => set((x) => x.copyWith(readerScale: v)),
      ),
      ChoiceRow<ReaderSpacing>(
        title: S.lineSpacing,
        value: s.readerSpacing,
        items: const [(ReaderSpacing.tight, S.lineTight), (ReaderSpacing.normal, S.lineNormal), (ReaderSpacing.wide, S.lineWide)],
        onChanged: (v) => set((x) => x.copyWith(readerSpacing: v)),
      ),
      ChoiceRow<bool>(
        title: S.alignment,
        value: s.justify,
        items: const [(false, S.alignLeft), (true, S.alignJustify)],
        onChanged: (v) => set((x) => x.copyWith(justify: v)),
      ),
    ]);
  }
}
