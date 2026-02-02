import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../constants.dart';

/// Helper para comunicação com DirectPin via Intent
class DirectPinIntentHelper {
  static const MethodChannel _channel = MethodChannel('com.example.directpin/intent');

  /// Cria uma Intent para enviar requisição ao DirectPin e aguarda resultado
  static Future<Map<String, dynamic>?> sendRequestAndWaitForResult(
    Map<String, dynamic> request,
  ) async {
    try {
      final requestJson = jsonEncode(request);
      
      // Usa MethodChannel para enviar e receber resultado
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'sendDirectPinIntent',
        {
          'action': Constants.directPinAction,
          'request': requestJson,
        },
      );

      if (result != null) {
        return Map<String, dynamic>.from(result);
      }
      return null;
    } catch (e) {
      print('Error sending DirectPin intent: $e');
      return null;
    }
  }

  /// Cria uma Intent para enviar requisição ao DirectPin (sem aguardar resultado)
  static AndroidIntent createRequestIntent(Map<String, dynamic> request) {
    final requestJson = jsonEncode(request);
    
    return AndroidIntent(
      action: Constants.directPinAction,
      arguments: {
        'request': requestJson,
      },
    );
  }

  /// Processa a resposta do DirectPin
  static T? processResponse<T>(
    Map<String, dynamic>? resultData, {
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    if (resultData == null) {
      return null;
    }

    final responseJson = resultData['response'] as String?;
    if (responseJson == null || responseJson.isEmpty) {
      return null;
    }

    try {
      final jsonMap = jsonDecode(responseJson) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      print('Error parsing response: $e');
      return null;
    }
  }
}
