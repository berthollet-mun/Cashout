import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

class ConnectivityService extends GetxService {
  static ConnectivityService get to => Get.find();
  
  final Connectivity _connectivity = Connectivity();
  final Rx<ConnectivityResult> connectionStatus = ConnectivityResult.none.obs;

  @override
  void onInit() {
    super.onInit();
    _initConnectivity();
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        connectionStatus.value = results.first;
      }
    });
  }

  Future<void> _initConnectivity() async {
    try {
      final List<ConnectivityResult> results = await _connectivity.checkConnectivity();
      if (results.isNotEmpty) {
        connectionStatus.value = results.first;
      }
    } catch (e) {
      print('Erreur Connectivity: $e');
    }
  }

  bool get isConnected => connectionStatus.value != ConnectivityResult.none;
}
