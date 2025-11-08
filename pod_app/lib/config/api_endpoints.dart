class ApiEndpoints {
  // Base URL - Change these for different environments
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1', // Development - Android emulator
    // Use 'http://localhost:8000/api/v1' for iOS simulator
  );
  
  // Production URLs (to be configured)
  static const String productionUrl = 'https://api.appyfly.com/v1';
  static const String stagingUrl = 'https://staging-api.appyfly.com/v1';
  
  // Auth endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String resetPassword = '/auth/reset-password';
  static const String verifyEmail = '/auth/verify-email';
  
  // User endpoints
  static const String userProfile = '/user/profile';
  static const String updateProfile = '/user/profile/update';
  static const String deleteAccount = '/user/delete';
  static const String userStats = '/user/stats';
  
  // Generation endpoints
  static const String generateImage = '/generation/create';
  static const String generationStatus = '/generation/status';
  static const String userGenerations = '/generation/user';
  static const String deleteGeneration = '/generation/delete';
  static const String regenerate = '/generation/regenerate';
  
  // Style endpoints
  static const String styles = '/styles/list';
  static const String styleDetails = '/styles/details';
  
  // Subscription endpoints
  static const String subscriptions = '/subscription/plans';
  static const String subscribe = '/subscription/create';
  static const String updateSubscription = '/subscription/update';
  static const String cancelSubscription = '/subscription/cancel';
  static const String subscriptionStatus = '/subscription/status';
  
  // Payment endpoints (Custom Cat)
  static const String createPaymentIntent = '/payment/create-intent';
  static const String confirmPayment = '/payment/confirm';
  static const String paymentHistory = '/payment/history';
  
  // Analytics endpoints
  static const String trackEvent = '/analytics/track';
  static const String userAnalytics = '/analytics/user';
  
  // Webhook endpoints (for backend)
  static const String customCatWebhook = '/webhook/customcat';
  static const String stripeWebhook = '/webhook/stripe';
  
  // Health check
  static const String healthCheck = '/health';
  static const String apiStatus = '/status';
}
