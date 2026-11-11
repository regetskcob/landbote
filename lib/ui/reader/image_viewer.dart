/// A full-screen image on Horizont's scrim, pinch to zoom.
library;

import 'package:flutter/material.dart';
import 'package:horizont/horizont.dart';

/// Shows [url] full screen.
Future<void> showImage(BuildContext context, String url, {String? alt}) => Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: HzScrim.bg,
        transitionDuration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : HzMotion.base,
        reverseTransitionDuration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : HzMotion.fast,
        pageBuilder: (context, _, _) => _Viewer(url: url, alt: alt),
        transitionsBuilder: (context, a, _, child) => FadeTransition(opacity: CurvedAnimation(parent: a, curve: HzMotion.standard), child: child),
      ),
    );

class _Viewer extends StatelessWidget {
  const _Viewer({required this.url, this.alt});

  final String url;
  final String? alt;

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: HzScrim.bg,
        appBar: AppBar(
          backgroundColor: HzScrim.bg.withValues(alpha: HzScrim.barAlpha),
          foregroundColor: HzScrim.text,
          leading: const CloseButton(),
        ),
        extendBodyBehindAppBar: true,
        body: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Column(children: [
            Expanded(
              child: InteractiveViewer(
                maxScale: 5,
                child: Center(child: Image.network(url, semanticLabel: alt, fit: BoxFit.contain)),
              ),
            ),
            if (alt != null && alt!.isNotEmpty)
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.all(HzSpace.s16),
                  child: Text(alt!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: HzScrim.textMuted)),
                ),
              ),
          ]),
        ),
      );
}
