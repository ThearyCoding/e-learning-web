import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import '../../models/topic_model.dart';
import '../../utils/toast_notification_config.dart';

const baseUrl = 'http://172.20.10.2:3000';

class ApiService {
   Future<void> uploadTopic(BuildContext context,String categoryId,Uint8List videoBytes, String filename, TopicModel topic) async {
    try {
      final url = Uri.parse('$baseUrl/api/topics/add-topic');
      final request = http.MultipartRequest('POST', url)
        ..fields['id'] = topic.id
        ..fields['title'] = topic.title
        ..fields['description'] = topic.description
        ..fields['categoryId'] = categoryId
        ..fields['courseId'] = topic.courseId
        ..files.add(http.MultipartFile.fromBytes(
          'video',
          videoBytes,
          filename: filename,
        ));

      final response = await request.send();
      if (response.statusCode == 200) {
        toastificationUtils(title: 'Success','Topic added successfully');
      } else {
        toastificationUtils('Failed to add topic');
      }
    } catch (e) {
      debugPrint('Error while sending $e');
      toastificationUtils('An error occurred');
    }
  }

  dynamic parseJson(String responseBody) {
    try {
      return jsonDecode(responseBody);
    } catch (e) {
      debugPrint('Error parsing JSON response: $e');
      return null;
    }
  }
}
