import 'package:flutter/foundation.dart';

String path(str) {
  return (kIsWeb) ? 'assets/$str' : str;
}

String assetPath(String assetName) {
  if (kIsWeb || kDebugMode) {
    return assetName;
  } else {
    return "assets/$assetName";
  }
}