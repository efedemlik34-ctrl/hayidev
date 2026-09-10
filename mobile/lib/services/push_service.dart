import 'package:flutter/material.dart';
import '../services/api.dart';
import '../services/socket.dart';

class PushService {
  static void init() {
    final socket = SocketService.socket;
    if (socket == null) return;

    socket.on('push', (data) {
      debugPrint('Push: ${data['title']} - ${data['body']}');
    });

    socket.on('notification', (data) {
      debugPrint('Bildirim: ${data['title']}');
    });

    socket.on('dm:new', (data) {
      debugPrint('DM: ${data['fromUsername']}: ${data['text']}');
    });
  }

  static Future<void> registerDevice(String fcmToken) async {
    try {
      await Api.dio.post('/push/register', data: {
        'token': fcmToken,
        'platform': 'android',
      });
    } catch (e) {
      debugPrint('Push register: $e');
    }
  }
}
