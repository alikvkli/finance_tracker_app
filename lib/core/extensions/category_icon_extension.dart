import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// Extension for mapping category icon names to various icon sets
extension CategoryIconExtension on String {
  /// Returns the appropriate Icon for the given category icon name
  /// Uses FontAwesome, Feather, and Material Icons for variety
  IconData getCategoryIcon() {
    switch (toLowerCase()) {
      // Home & Living
      case 'home':
        return FontAwesomeIcons.house;
      case 'rent':
        return FontAwesomeIcons.building;
      case 'utilities':
        return FontAwesomeIcons.bolt;
      case 'water_drop':
        return FontAwesomeIcons.droplet;
      case 'local_fire_department':
        return FontAwesomeIcons.fire;
      case 'wifi':
        return FontAwesomeIcons.wifi;
      case 'phone':
        return FontAwesomeIcons.phone;
      
      // Income & Finance
      case 'salary':
        return FontAwesomeIcons.briefcase;
      case 'freelance':
        return FontAwesomeIcons.laptop;
      case 'investment':
        return FontAwesomeIcons.chartLine;
      case 'dividend':
        return FontAwesomeIcons.coins;
      case 'bonus':
        return FontAwesomeIcons.gift;
      case 'trending_up':
        return FontAwesomeIcons.arrowTrendUp;
      case 'currency_bitcoin':
        return FontAwesomeIcons.bitcoin;
      case 'account_balance':
        return FontAwesomeIcons.buildingColumns;
      case 'business':
        return FontAwesomeIcons.building;
      
      // Food & Dining
      case 'food':
        return FontAwesomeIcons.utensils;
      case 'restaurant':
        return FontAwesomeIcons.utensils;
      case 'local_cafe':
        return FontAwesomeIcons.mugHot;
      case 'fastfood':
        return FontAwesomeIcons.hamburger;
      case 'grocery':
        return FontAwesomeIcons.cartShopping;
      case 'coffee':
        return FontAwesomeIcons.coffee;
      
      // Transportation
      case 'transport':
        return FontAwesomeIcons.bus;
      case 'directions_car':
        return FontAwesomeIcons.bus;
      case 'car':
        return FontAwesomeIcons.car;
      case 'gas':
        return FontAwesomeIcons.gasPump;
      case 'public_transport':
        return FontAwesomeIcons.bus;
      case 'taxi':
        return FontAwesomeIcons.taxi;
      case 'flight':
        return FontAwesomeIcons.plane;
      case 'train':
        return FontAwesomeIcons.train;
      
      // Shopping & Retail
      case 'shopping':
        return FontAwesomeIcons.bagShopping;
      case 'shopping_cart':
        return FontAwesomeIcons.cartShopping;
      case 'shopping_bag':
        return FontAwesomeIcons.bagShopping;
      case 'market':
        return FontAwesomeIcons.store;
      case 'clothing':
        return FontAwesomeIcons.shirt;
      case 'electronics':
        return FontAwesomeIcons.laptop;
      case 'books':
        return FontAwesomeIcons.book;
      case 'checkroom':
        return FontAwesomeIcons.shirt;
      
      // Entertainment & Leisure
      case 'entertainment':
        return FontAwesomeIcons.film;
      case 'movie':
        return FontAwesomeIcons.video;
      case 'music':
        return FontAwesomeIcons.music;
      case 'games':
        return FontAwesomeIcons.gamepad;
      case 'sports':
        return FontAwesomeIcons.football;
      case 'gym':
        return FontAwesomeIcons.dumbbell;
      case 'travel':
        return FontAwesomeIcons.plane;
      case 'vacation':
        return FontAwesomeIcons.umbrellaBeach;
      
      // Health & Medical
      case 'health':
        return FontAwesomeIcons.heartPulse;
      case 'medical':
        return FontAwesomeIcons.stethoscope;
      case 'pharmacy':
        return FontAwesomeIcons.pills;
      case 'dentist':
        return FontAwesomeIcons.tooth;
      case 'local_hospital':
        return FontAwesomeIcons.hospital;
      case 'insurance':
        return FontAwesomeIcons.shield;
      
      // Education & Learning
      case 'education':
        return FontAwesomeIcons.graduationCap;
      case 'school':
        return FontAwesomeIcons.school;
      case 'university':
        return FontAwesomeIcons.buildingColumns;
      case 'course':
        return FontAwesomeIcons.bookOpen;
      case 'training':
        return FontAwesomeIcons.chalkboard;
      
      // Technology & Communication
      case 'internet':
        return FontAwesomeIcons.globe;
      case 'software':
        return FontAwesomeIcons.code;
      case 'subscription':
        return FontAwesomeIcons.creditCard;
      case 'cloud':
        return FontAwesomeIcons.cloud;
      case 'mobile':
        return FontAwesomeIcons.mobile;
      
      // Personal & Family
      case 'gift':
        return FontAwesomeIcons.gift;
      case 'family':
        return FontAwesomeIcons.users;
      case 'children':
        return FontAwesomeIcons.child;
      case 'pets':
        return FontAwesomeIcons.paw;
      case 'personal_care':
        return FontAwesomeIcons.spa;
      
      // Services & Professional
      case 'legal':
        return FontAwesomeIcons.scaleBalanced;
      case 'accounting':
        return FontAwesomeIcons.calculator;
      case 'consulting':
        return FontAwesomeIcons.handshake;
      case 'maintenance':
        return FontAwesomeIcons.tools;
      case 'cleaning':
        return FontAwesomeIcons.broom;
      
      // Miscellaneous
      case 'receipt':
        return FontAwesomeIcons.receipt;
      case 'receipt_long':
        return FontAwesomeIcons.fileInvoice;
      case 'credit_card':
        return FontAwesomeIcons.creditCard;
      case 'cash':
        return FontAwesomeIcons.moneyBill;
      case 'donation':
        return FontAwesomeIcons.handHoldingHeart;
      case 'charity':
        return FontAwesomeIcons.heart;
      case 'more':
        return FontAwesomeIcons.layerGroup;
      case 'bes':
        return FontAwesomeIcons.hand;
      case 'flash_on':
        return FontAwesomeIcons.bolt;
      
      // Lucide Icons for specific cases
      case 'lucide_home':
        return LucideIcons.home;
      case 'lucide_car':
        return LucideIcons.car;
      case 'lucide_shopping':
        return LucideIcons.shoppingBag;
      case 'lucide_heart':
        return LucideIcons.heart;
      case 'lucide_book':
        return LucideIcons.book;
      case 'lucide_plane':
        return LucideIcons.plane;
      case 'lucide_phone':
        return LucideIcons.phone;
      case 'lucide_wifi':
        return LucideIcons.wifi;
      case 'lucide_gift':
        return LucideIcons.gift;
      case 'lucide_credit_card':
        return LucideIcons.creditCard;
      
      default:
        return FontAwesomeIcons.coins;
    }
  }
}
