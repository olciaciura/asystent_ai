import 'dart:developer';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:asystent_ai/style/style.dart';

export 'process_response_message.dart' show processResponseMessage;

List<dynamic> extractPredictions(String responseMessage) {
  final jsonPart = responseMessage.replaceFirst('Success: ', '').trim();
  final List<dynamic> decoded = jsonDecode(jsonPart);
  return decoded;
}

dynamic processResponseMessage(dynamic responseMessage) {
  if (responseMessage == null) {
    return "";
  }

  final List<dynamic> predictions = extractPredictions(
    responseMessage.toString(),
  );

  if (predictions.isNotEmpty) {
    // Sortuj po confidence malejąco
    predictions.sort(
      (a, b) => (b['confidence'] as num).compareTo(a['confidence'] as num),
    );
    final List<Map<String, dynamic>> plants = List.from(
      predictions.map((e) => e['plant']),
    );
    // log(plants.toString());
    return plants;
  }
  // Domyślnie zwróć responseMessage jako string
  return responseMessage.toString();
}
