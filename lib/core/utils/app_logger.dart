import 'dart:convert';

import 'package:flutter/foundation.dart';

enum AppLogLevel { debug, info, warning, error }

class AppLogger {
  AppLogger._();

  static const bool _enableReleaseLogs = bool.fromEnvironment(
    'ENABLE_APP_LOGS',
    defaultValue: false,
  );

  static bool get _enabled {
    return kDebugMode || _enableReleaseLogs;
  }

  static const int _maxLogLength = 900;

  static const Set<String> _sensitiveKeys = {
    'password',
    'confirmPassword',
    'oldPassword',
    'newPassword',
    'token',
    'accessToken',
    'refreshToken',
    'authorization',
    'auth',
    'apiKey',
    'secret',
    'pin',
    'otp',
    'session',
    'cookie',
  };

  static void d(String message, {String tag = 'APP', Object? data}) {
    _log(AppLogLevel.debug, message, tag: tag, data: data);
  }

  static void i(String message, {String tag = 'APP', Object? data}) {
    _log(AppLogLevel.info, message, tag: tag, data: data);
  }

  static void w(String message, {String tag = 'APP', Object? data}) {
    _log(AppLogLevel.warning, message, tag: tag, data: data);
  }

  static void e(
    String message, {
    String tag = 'APP',
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    _log(
      AppLogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
      data: data,
    );
  }

  static void _log(
    AppLogLevel level,
    String message, {
    required String tag,
    Object? error,
    StackTrace? stackTrace,
    Object? data,
  }) {
    if (!_enabled) return;

    final buffer = StringBuffer();

    buffer.write('${_levelText(level)} [$tag] ');
    buffer.write(_sanitizeText(message));

    if (data != null) {
      buffer.write('\nDATA: ');
      buffer.write(_safeEncode(data));
    }

    if (error != null) {
      buffer.write('\nERROR: ');
      buffer.write(_sanitizeText(error.toString()));
    }

    if (stackTrace != null && kDebugMode) {
      buffer.write('\nSTACK: ');
      buffer.write(stackTrace.toString());
    }

    _printLong(buffer.toString());
  }

  static String _levelText(AppLogLevel level) {
    switch (level) {
      case AppLogLevel.debug:
        return 'DEBUG';
      case AppLogLevel.info:
        return 'INFO';
      case AppLogLevel.warning:
        return 'WARNING';
      case AppLogLevel.error:
        return 'ERROR';
    }
  }

  static String _safeEncode(Object data) {
    try {
      final sanitized = _sanitizeObject(data);
      return _sanitizeText(jsonEncode(sanitized));
    } catch (_) {
      return _sanitizeText(data.toString());
    }
  }

  static Object? _sanitizeObject(Object? value) {
    if (value == null) return null;

    if (value is Map) {
      return value.map((key, val) {
        final keyText = key.toString();

        if (_isSensitiveKey(keyText)) {
          return MapEntry(keyText, '***');
        }

        return MapEntry(keyText, _sanitizeObject(val));
      });
    }

    if (value is List) {
      return value.map(_sanitizeObject).toList();
    }

    if (value is String) {
      return _sanitizeText(value);
    }

    return value;
  }

  static bool _isSensitiveKey(String key) {
    final normalizedKey = key.toLowerCase();

    return _sensitiveKeys.any(
      (sensitiveKey) => normalizedKey.contains(sensitiveKey.toLowerCase()),
    );
  }

  static String _sanitizeText(String text) {
    var result = text;

    result = result.replaceAll(
      RegExp(r'Bearer\s+[A-Za-z0-9\-\._~\+\/]+=*', caseSensitive: false),
      'Bearer ***',
    );

    result = result.replaceAll(
      RegExp(r'Basic\s+[A-Za-z0-9\-\._~\+\/]+=*', caseSensitive: false),
      'Basic ***',
    );

    result = result.replaceAll(
      RegExp(r'([A-Za-z0-9._%+-]+)@([A-Za-z0-9.-]+\.[A-Za-z]{2,})'),
      '***@***',
    );

    result = result.replaceAll(
      RegExp(
        r'("(?:password|token|accessToken|refreshToken|apiKey|secret|authorization)"\s*:\s*")[^"]+(")',
        caseSensitive: false,
      ),
      r'$1***$2',
    );

    return result;
  }

  static void _printLong(String text) {
    if (text.length <= _maxLogLength) {
      debugPrint(text);
      return;
    }

    for (var i = 0; i < text.length; i += _maxLogLength) {
      final end = (i + _maxLogLength < text.length)
          ? i + _maxLogLength
          : text.length;

      debugPrint(text.substring(i, end));
    }
  }
}
