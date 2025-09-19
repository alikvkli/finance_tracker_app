class ApiConfig {
  // Base API URL
  static const String baseUrl = 'http://127.0.0.1:8000';
  //'https://finans.kiracilarim.com';
  
  // API Endpoints
  static const String registerEndpoint = '/api/register';
  static const String loginEndpoint = '/api/login';
  static const String logoutEndpoint = '/api/logout';
  static const String profileEndpoint = '/api/profile';
  static const String transactionsEndpoint = '/api/transactions';
  static const String categoriesEndpoint = '/api/categories';
  
  // Request Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
