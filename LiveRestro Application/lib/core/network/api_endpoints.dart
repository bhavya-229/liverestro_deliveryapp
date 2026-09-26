class ApiEndpoints {
  // Local development mock server
  // On Physical Device (Wi-Fi): use your PC's IP address (192.168.29.246)
  // On Android Emulator: 'http://10.0.2.2:4000/api/v1'
  // On Web / Desktop: 'http://localhost:4000/api/v1'
  // For production: 'https://liverestro.com/api/v1'
  static const String physicalDeviceUrl = 'http://192.168.29.246:4000/api/v1';
  static const String emulatorUrl = 'http://10.0.2.2:4000/api/v1';
  static const String localhostUrl = 'http://localhost:4000/api/v1';

  // Mode switch: Set to false to fetch all live restaurants from the server (with fallback to local if unreachable)
  static const bool useOfflineMockOnly = false;

  // Active base URL for local testing (pointing to your computer on the Wi-Fi network)
  static const String baseUrl = physicalDeviceUrl;

  static const String customerAuth = '/customers/auth';
  static const String customerAddresses = '/customers';

  static const String restaurants = '/restaurants';
  static String restaurantDetails(String id) => '/restaurants/$id';
  static String restaurantMenu(String id) => '/restaurants/$id/menu';

  static const String createOrder = '/orders/create';
  static String orderStatus(String orderId) => '/orders/$orderId/status';
  static String posOrderAction(String orderId) => '/pos/orders/$orderId/action';
}
