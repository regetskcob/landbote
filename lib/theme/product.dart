import 'package:flutter/widgets.dart';
import 'package:horizont/horizont.dart';

/// Landbote as a product on Horizont: the accent "Altrhein" and the glyph.
///
/// Since Horizont 0.16.0 these decisions live here, not in Horizont. The
/// values mirror `tool/horizont/horizont.product.json` (the form Horizont's
/// web layer and tools read); `test/ui/product_test.dart` holds the two together and
/// checks the colours against Horizont's contrast rules. Change a colour in
/// both files.
const landbote = HorizontProduct(
  id: 'landbote',
  displayName: 'Landbote',
  accentName: 'Altrhein',
  light: HzAccent(
    accent: Color(0xFF1E6B66),
    onAccent: Color(0xFFFFFFFF),
    accentTint: Color(0xFFE2EFED),
    accentText: Color(0xFF1B6661),
  ),
  dark: HzAccent(
    accent: Color(0xFF6FC7BC),
    onAccent: Color(0xFF0C1F1D),
    accentTint: Color(0xFF172826),
    accentText: Color(0xFF80CFC5),
  ),
  mark: HorizontGlyph(_mailbox, thin: _seam),
);

// The mailbox on its post at the edge of the field, the flag raised. Drawn in a box of 100 by 100 with the
// horizon at 66.7; `HorizontMark` strokes it 7 wide with square caps. The
// source is `tool/horizont/mark/glyph.svg`.
Path _mailbox() => Path()
  // The horizon and the post.
  ..moveTo(4, 66.7)
  ..lineTo(96, 66.7)
  ..moveTo(50, 66.7)
  ..lineTo(50, 46)
  // The box with its rounded top.
  ..moveTo(22, 46)
  ..lineTo(22, 37)
  ..arcToPoint(const Offset(31, 28), radius: const Radius.circular(9))
  ..lineTo(65, 28)
  ..arcToPoint(const Offset(74, 37), radius: const Radius.circular(9))
  ..lineTo(74, 46)
  ..close()
  // The flag, raised: staff and cloth as two strokes with square ends.
  ..moveTo(66, 28)
  ..lineTo(66, 13.5)
  ..moveTo(66, 13.5)
  ..lineTo(76, 13.5);

/// The door seam, at half the stroke.
Path _seam() => Path()
  ..moveTo(32, 31)
  ..lineTo(32, 43);
