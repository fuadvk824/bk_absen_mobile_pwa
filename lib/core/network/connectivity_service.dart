import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  final Connectivity connectivity = Connectivity();

  StreamSubscription? _subscription;

  void listen(void Function() onOnline) {
    _subscription = connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.any((r) => r != ConnectivityResult.none);

      if (isConnected) {
        onOnline();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }
}
