import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseApiNotifications {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> markAsReadForUsersWithToken(
    String notificationId,
    String message,
    String title, {
    String? courseId,
    String? categoryId,
  }) async {
    try {
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      // Iterate over each user
      for (final userDoc in usersSnapshot.docs) {
        // Check if the user document contains 'fcmToken' field
        if (userDoc.data().containsKey('fcmToken')) {
          final userId = userDoc.id;

          // Update the specific notification for each user
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('notifications')
              .doc(notificationId)
              .set({
            'title': title,
            'message': message,
            'timestamp': Timestamp.now(),
            'id': notificationId,
            'type': courseId != null ? 'course' : 'announcement',
            'isRead': false,
            'courseId': courseId,
            'categoryId': categoryId,
          });
        }
      }

      debugPrint('Notification marked as read for users with fcmToken');
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }
}
