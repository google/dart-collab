#library('utils');

String ALPHABET = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

String randomId() {
  StringBuffer sb = new StringBuffer();
  for (int i = 0; i < 12; i++) {
    int c = (Math.random() * ALPHABET.length).floor().toInt();
    sb.add(ALPHABET[c]);
  }
  return sb.toString();
}

Map<String, Object> mergeMaps(Map<String, Object> a, Map<String, Object> b) {
  Map<String, Object> merged = (a == null) ? new Map() : new Map.from(a);
  b.forEach((k, v) { merged[k] = v; });
  return merged;
}
