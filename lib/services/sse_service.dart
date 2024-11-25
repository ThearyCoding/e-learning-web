import 'dart:convert';
import 'package:flutter_client_sse/constants/sse_request_type_enum.dart';
import 'package:flutter_client_sse/flutter_client_sse.dart';

class SseService {
  final String url;

  SseService(this.url);

  void listenToProgressUpdates(Function(double) onProgress) {
    SSEClient.subscribeToSSE(
      method: SSERequestType.GET,
      url: url,
      header: {
        "Accept": "text/event-stream",
        "Cache-Control": "no-cache",
      },
    ).listen((event) {
      final eventData = event.data;
      if (eventData != null && eventData.isNotEmpty) {
        final progressData = jsonDecode(eventData);
        if (progressData['progress'] != null) {
          onProgress(progressData['progress'].toDouble());
        }
      }
    }, onError: (error) {
      print("Error in SSE: $error");
    });
  }
}
