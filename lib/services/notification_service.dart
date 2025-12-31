import 'dart:async';
import 'package:flutter/material.dart';

class NotificationItem {
  final String id;
  final String message;
  final String? details;
  final Duration duration;

  NotificationItem({
    required this.id,
    required this.message,
    this.details,
    this.duration = const Duration(seconds: 5),
  });
}

class NotificationService extends ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final List<NotificationItem> _notifications = [];
  List<NotificationItem> get notifications => _notifications;

  void showNotification(NotificationItem item) {
    _notifications.add(item);
    notifyListeners();
    Timer(item.duration, () {
      if (_notifications.contains(item)) {
        _notifications.remove(item);
        notifyListeners();
      }
    });
  }
}
