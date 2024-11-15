// notification_provider.dart
import 'package:flutter/material.dart';

class NotificationProvider with ChangeNotifier {
  int _notificationCount = 1;

  int get notificationCount => _notificationCount;

  void addNotification() {
    _notificationCount++;
    notifyListeners();
  }

  void clearNotifications() {
    _notificationCount = 0;
    notifyListeners();
  }
}
