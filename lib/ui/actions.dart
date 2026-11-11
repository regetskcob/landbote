/// Outward actions shared by list and reader: open, share, copy.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:horizont/horizont.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app/settings.dart';
import '../l10n/strings.dart';

/// Opens [url]: in the system's in-app browser (Safari View Controller,
/// Custom Tabs) or the default browser, as the person chose.
Future<void> openLink(WidgetRef ref, String url, {bool forceBrowser = false}) async {
  final uri = Uri.tryParse(url);
  if (uri == null) return;
  final inApp = ref.read(settingsProvider).openInApp && !forceBrowser && (uri.scheme == 'http' || uri.scheme == 'https');
  final ok = await launchUrl(uri, mode: inApp ? LaunchMode.inAppBrowserView : LaunchMode.externalApplication);
  if (!ok) await launchUrl(uri, mode: LaunchMode.platformDefault);
}

/// Shares [url] with [title] through the system sheet.
Future<void> shareLink(BuildContext context, String url, String title) async {
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(ShareParams(
    uri: Uri.tryParse(url),
    subject: title,
    sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size,
  ));
}

/// Copies [url] and says so.
Future<void> copyLink(BuildContext context, String url) async {
  final messenger = ScaffoldMessenger.of(context);
  final colors = HorizontTheme.of(context).colors;
  await Clipboard.setData(ClipboardData(text: url));
  messenger.showSnackBar(horizontMessageSnackBar(colors, S.linkCopied, status: HorizontStatus.positive));
}
