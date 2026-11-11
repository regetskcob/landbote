/// Removes tracking parameters from links before they are stored or shared.
library;

const _exact = {
  'fbclid', 'gclid', 'dclid', 'msclkid', 'mc_cid', 'mc_eid', 'igshid',
  'yclid', '_hsenc', '_hsmi', 'mkt_tok', 'oly_anon_id', 'oly_enc_id',
  'vero_id', 'wt_mc', 'ref_src', 'spm',
};

/// [url] without `utm_*` and other known click-tracking parameters. The
/// fragment and all other parameters stay as they were.
String stripTracking(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null || !uri.hasQuery) return url;
  final kept = <String, List<String>>{};
  var removed = false;
  uri.queryParametersAll.forEach((key, values) {
    final k = key.toLowerCase();
    if (k.startsWith('utm_') || _exact.contains(k)) {
      removed = true;
    } else {
      kept[key] = values;
    }
  });
  if (!removed) return url;
  final query = [
    for (final e in kept.entries)
      for (final v in e.value) v.isEmpty ? Uri.encodeQueryComponent(e.key) : '${Uri.encodeQueryComponent(e.key)}=${Uri.encodeQueryComponent(v)}',
  ].join('&');
  final base = uri.replace(query: '', fragment: '').toString().replaceAll(RegExp(r'[?#]+$'), '');
  return '$base${query.isEmpty ? '' : '?$query'}${uri.hasFragment ? '#${uri.fragment}' : ''}';
}
