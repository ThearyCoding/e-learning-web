import 'dart:convert';
import 'package:e_learningapp_admin/core/constant.dart';
import 'package:e_learningapp_admin/export/export.dart';
import 'package:http/http.dart' as http;


class NotficationService{
 static Future<void> sendPushNotificationToAll(
      String title, String body, String courseId, String categoryId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/send-notification-to-all'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'title': title,
          'body': body,
          'courseId': courseId,
          'categoryId': categoryId,
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Notifications sent successfully');
      } else {
        debugPrint('Failed to send notifications');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      debugPrint('Failed to send notifications: $e');
    }
  }
}