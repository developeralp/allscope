import 'package:connectivity/connectivity.dart';

class NetworkTool {
  NetworkTool._privateConstructor();

  static final NetworkTool _instance = NetworkTool._privateConstructor();

  static NetworkTool get instance => _instance;

  bool networkAvailable;
  bool broadcastDownloading;

  Future<bool> checkNetwork() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      this.networkAvailable = true;
      return true;
    } else {
      this.networkAvailable = false;
      return false;
    }
  }
}
