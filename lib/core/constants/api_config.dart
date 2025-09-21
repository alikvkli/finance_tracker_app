class ApiConfig {
  // Base API URL
  static const String baseUrl = 'https://finans.kiracilarim.com';
  
  // API Endpoints
  static const String registerEndpoint = '/api/register';
  static const String loginEndpoint = '/api/login';
  static const String logoutEndpoint = '/api/logout';
  static const String profileEndpoint = '/api/profile';
  static const String deleteAccountEndpoint = '/api/delete-account';
  static const String transactionsEndpoint = '/api/transactions';
  static const String transactionsStatisticsEndpoint = '/api/transactions/statistics';
  static const String categoriesEndpoint = '/api/categories';
  static const String recurringTransactionsEndpoint = '/api/recurring-transactions';
  static const String notificationsEndpoint = '/api/notifications';
  static const String configEndpoint = '/api/config';
  
  // Request Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Headers
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
