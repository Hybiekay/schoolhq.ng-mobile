import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:schoolhq_ng/models/school_model.dart';

String resolveDashboardApiBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:30011/api';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:30011/api';
  }
  return 'http://localhost:30011/api';
}

String resolveSchoolApiBaseUrl(SchoolModel? school) {
  final appUrl = school?.appUrl.trim() ?? '';
  if (appUrl.isEmpty) {
    return _resolveLegacySchoolApiBaseUrl();
  }

  return _normalizeSchoolApiUrl(appUrl);
}

String _resolveLegacySchoolApiBaseUrl() {
  if (kIsWeb) {
    return 'http://localhost:8000/api';
  }
  if (Platform.isAndroid) {
    return 'http://10.0.2.2:8000/api';
  }
  return 'http://localhost:8000/api';
}

String _normalizeSchoolApiUrl(String rawUrl) {
  final uri = Uri.tryParse(rawUrl);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    return _resolveLegacySchoolApiBaseUrl();
  }

  var normalized = uri;
  if (!kIsWeb &&
      Platform.isAndroid &&
      (normalized.host == 'localhost' || normalized.host == '127.0.0.1')) {
    normalized = normalized.replace(host: '10.0.2.2');
  }

  final segments = normalized.pathSegments
      .where((segment) => segment.isNotEmpty)
      .toList();
  if (segments.isEmpty || segments.last.toLowerCase() != 'api') {
    segments.add('api');
  }

  return normalized.replace(pathSegments: segments).toString();
}
