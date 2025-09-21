import 'package:flutter/material.dart';

/// Extension for mapping category icon names to Material Icons
extension CategoryIconExtension on String {
  /// Returns the appropriate Material Icon for the given category icon name
  IconData getCategoryIcon() {
    switch (toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'salary':
        return Icons.work;
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'health':
        return Icons.health_and_safety;
      case 'education':
        return Icons.school;
      case 'travel':
        return Icons.flight;
      case 'gift':
        return Icons.card_giftcard;
      case 'flash_on':
        return Icons.flash_on;
      case 'water_drop':
        return Icons.water_drop;
      case 'local_fire_department':
        return Icons.local_fire_department;
      case 'wifi':
        return Icons.wifi;
      case 'phone':
        return Icons.phone;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'restaurant':
        return Icons.restaurant;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'fastfood':
        return Icons.fastfood;
      case 'trending_up':
        return Icons.trending_up;
      case 'currency_bitcoin':
        return Icons.currency_bitcoin;
      case 'account_balance':
        return Icons.account_balance;
      case 'receipt_long':
        return Icons.receipt_long;
      case 'business':
        return Icons.business;
      case 'more':
        return Icons.more_horiz;
      case 'directions_car':
        return Icons.directions_car;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'movie':
        return Icons.movie;
      case 'credit_card':
        return Icons.credit_card;
      case 'checkroom':
        return Icons.checkroom;
      case 'receipt':
        return Icons.receipt;
      case 'market':
        return Icons.shopping_cart;
      default:
        return Icons.category;
    }
  }
}
