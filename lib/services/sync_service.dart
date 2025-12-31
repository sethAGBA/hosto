import 'dart:async';

class SyncService {
  Timer? _timer;

  Future<void> runOnce() async {
    // Placeholder for future sync logic (offline -> online).
  }

  void startPeriodic({Duration interval = const Duration(minutes: 5)}) {
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) {
      runOnce();
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
