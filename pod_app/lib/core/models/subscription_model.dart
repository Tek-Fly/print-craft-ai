import 'dart:convert';

enum SubscriptionStatus {
  active,
  cancelled,
  expired,
  pending,
  paused,
  trial
}

enum BillingPeriod {
  weekly,
  monthly,
  yearly
}

class SubscriptionModel {
  final String id;
  final String userId;
  final String productId;
  final SubscriptionStatus status;
  final BillingPeriod billingPeriod;
  final double price;
  final String currency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? nextBillingDate;
  final DateTime? cancelledAt;
  final bool isTrialPeriod;
  final int? trialDaysRemaining;
  final String? paymentMethod;
  final String? customCatCustomerId;
  final String? customCatSubscriptionId;
  final Map<String, dynamic>? metadata;
  
  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.productId,
    required this.status,
    required this.billingPeriod,
    required this.price,
    this.currency = 'USD',
    required this.startDate,
    this.endDate,
    this.nextBillingDate,
    this.cancelledAt,
    this.isTrialPeriod = false,
    this.trialDaysRemaining,
    this.paymentMethod,
    this.customCatCustomerId,
    this.customCatSubscriptionId,
    this.metadata,
  });
  
  bool get isActive => 
      status == SubscriptionStatus.active || 
      status == SubscriptionStatus.trial;
  
  bool get isCancelled => status == SubscriptionStatus.cancelled;
  
  bool get isExpired => status == SubscriptionStatus.expired;
  
  String get formattedPrice {
    final symbol = currency == 'USD' ? '\$' : currency;
    return '$symbol${price.toStringAsFixed(2)}';
  }
  
  String get billingPeriodLabel {
    switch (billingPeriod) {
      case BillingPeriod.weekly:
        return 'week';
      case BillingPeriod.monthly:
        return 'month';
      case BillingPeriod.yearly:
        return 'year';
    }
  }
  
  String get priceLabel => '$formattedPrice/$billingPeriodLabel';
  
  int? get daysUntilRenewal {
    if (nextBillingDate == null) return null;
    return nextBillingDate!.difference(DateTime.now()).inDays;
  }
  
  SubscriptionModel copyWith({
    String? id,
    String? userId,
    String? productId,
    SubscriptionStatus? status,
    BillingPeriod? billingPeriod,
    double? price,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? nextBillingDate,
    DateTime? cancelledAt,
    bool? isTrialPeriod,
    int? trialDaysRemaining,
    String? paymentMethod,
    String? customCatCustomerId,
    String? customCatSubscriptionId,
    Map<String, dynamic>? metadata,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      status: status ?? this.status,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      isTrialPeriod: isTrialPeriod ?? this.isTrialPeriod,
      trialDaysRemaining: trialDaysRemaining ?? this.trialDaysRemaining,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      customCatCustomerId: customCatCustomerId ?? this.customCatCustomerId,
      customCatSubscriptionId: customCatSubscriptionId ?? this.customCatSubscriptionId,
      metadata: metadata ?? this.metadata,
    );
  }
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'status': status.name,
      'billingPeriod': billingPeriod.name,
      'price': price,
      'currency': currency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
      'isTrialPeriod': isTrialPeriod,
      'trialDaysRemaining': trialDaysRemaining,
      'paymentMethod': paymentMethod,
      'customCatCustomerId': customCatCustomerId,
      'customCatSubscriptionId': customCatSubscriptionId,
      'metadata': metadata,
    };
  }
  
  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      productId: map['productId'] as String,
      status: SubscriptionStatus.values.byName(map['status'] as String),
      billingPeriod: BillingPeriod.values.byName(map['billingPeriod'] as String),
      price: (map['price'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: map['endDate'] != null
          ? DateTime.parse(map['endDate'] as String)
          : null,
      nextBillingDate: map['nextBillingDate'] != null
          ? DateTime.parse(map['nextBillingDate'] as String)
          : null,
      cancelledAt: map['cancelledAt'] != null
          ? DateTime.parse(map['cancelledAt'] as String)
          : null,
      isTrialPeriod: map['isTrialPeriod'] as bool? ?? false,
      trialDaysRemaining: map['trialDaysRemaining'] as int?,
      paymentMethod: map['paymentMethod'] as String?,
      customCatCustomerId: map['customCatCustomerId'] as String?,
      customCatSubscriptionId: map['customCatSubscriptionId'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  }
  
  String toJson() => json.encode(toMap());
  
  factory SubscriptionModel.fromJson(String source) =>
      SubscriptionModel.fromMap(json.decode(source) as Map<String, dynamic>);
  
  // Factory for creating a trial subscription
  factory SubscriptionModel.trial({
    required String id,
    required String userId,
    required String productId,
    required BillingPeriod billingPeriod,
    required double price,
    int trialDays = 7,
  }) {
    final now = DateTime.now();
    final trialEndDate = now.add(Duration(days: trialDays));
    
    return SubscriptionModel(
      id: id,
      userId: userId,
      productId: productId,
      status: SubscriptionStatus.trial,
      billingPeriod: billingPeriod,
      price: price,
      startDate: now,
      nextBillingDate: trialEndDate,
      isTrialPeriod: true,
      trialDaysRemaining: trialDays,
    );
  }
}
