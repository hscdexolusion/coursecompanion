class WebNotificationService {
  static final WebNotificationService _instance = WebNotificationService._internal();
  factory WebNotificationService() => _instance;
  WebNotificationService._internal();

  bool _isInitialized = true;

  bool get isSupported => false;
  bool get isInitialized => _isInitialized;
  bool get hasPermission => false;

  Future<void> initialize() async {
    _isInitialized = true;
  }

  Future<bool> requestPermission() async => false;

  Future<void> showNotification({
    required String title,
    required String body,
    String? icon,
    String? tag,
    Map<String, dynamic>? data,
  }) async {}

  Future<void> scheduleNotification({
    required String title,
    required String body,
    required Duration delay,
    String? icon,
    String? tag,
    Map<String, dynamic>? data,
  }) async {}

  Future<void> cancelAllNotifications() async {}
  Future<void> cancelNotification(String tag) async {}
}
