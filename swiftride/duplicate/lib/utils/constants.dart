// lib/utils/constants.dart

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
const Color kNavy    = Color(0xFF0A0E21);
const Color kNavy2   = Color(0xFF12172E);
const Color kGold    = Color(0xFFD4A017);
const Color kGoldL   = Color(0xFFE8C04A);
const Color kSurf    = Color(0xFF1A2035);
const Color kSurf2   = Color(0xFF222840);
const Color kText    = Color(0xFFEEEEF5);
const Color kTextS   = Color(0xFF8A8FA8);
const Color kError   = Color(0xFFD85A30);
const Color kSuccess = Color(0xFF1D9E75);
const Color kWarn    = Color(0xFFE8C04A);

// Re-export AppColors so files that import from here get it too
class AppColors {
  static const gold        = Color(0xFFD4A017);
  static const goldLight   = Color(0xFFE8C04A);
  static const darkBg      = Color(0xFF0A0E1A);
  static const darkCard    = Color(0xFF141828);
  static const darkSurface = Color(0xFF1C2236);
  static const darkBorder  = Color(0xFF252B3E);
  static const white       = Colors.white;
  static const lightBg     = Color(0xFFF2F4F8);
  static const lightCard   = Color(0xFFFFFFFF);
  static const lightSurface= Color(0xFFE8EBF2);
}

// ─────────────────────────────────────────────
//  CATEGORIES
// ─────────────────────────────────────────────
const List<String> kCategories = [
  'All', 'Electric', 'Sports', 'SUV', 'Luxury', 'Economy', '4x4', 'Van',
];

// ─────────────────────────────────────────────
//  PICKUP LOCATIONS
// ─────────────────────────────────────────────
const List<String> kPickupLocations = [
  'Kigali City Centre',
  'Kigali International Airport',
  'Nyamirambo',
  'Kimironko Market',
  'Gisozi',
  'Nyarutarama',
  'Remera',
  'Kicukiro',
];

// ─────────────────────────────────────────────
//  ALL CARS
// ─────────────────────────────────────────────
final List<Map<String, dynamic>> kAllCars = [
  {
    'id': '1',
    'name': 'Tesla Model S',
    'brand': 'Tesla',
    'year': '2023',
    'category': 'Electric',
    'price': 120,
    'rating': 4.9,
    'seats': 5,
    'transmission': 'Auto',
    'fuel': 'Electric',
    'range': '405 mi',
    'color': 0xFF1A237E,
    'desc': 'The Tesla Model S is an all-electric luxury sedan with impressive range and performance. Features over-the-air updates and autopilot capabilities.',
  },
  {
    'id': '2',
    'name': 'BMW M5',
    'brand': 'BMW',
    'year': '2022',
    'category': 'Sports',
    'price': 150,
    'rating': 4.8,
    'seats': 5,
    'transmission': 'Auto',
    'fuel': 'Petrol',
    'range': '310 mi',
    'color': 0xFF880E4F,
    'desc': 'The BMW M5 is a high-performance sports sedan with a twin-turbocharged V8 engine. Offers an exhilarating driving experience with luxury comfort.',
  },
  {
    'id': '3',
    'name': 'Range Rover',
    'brand': 'Land Rover',
    'year': '2023',
    'category': 'SUV',
    'price': 180,
    'rating': 4.7,
    'seats': 7,
    'transmission': 'Auto',
    'fuel': 'Diesel',
    'range': '350 mi',
    'color': 0xFF1B5E20,
    'desc': 'The Range Rover combines luxury with off-road capability. Perfect for both city driving and adventure across Rwanda\'s varied terrain.',
  },
  {
    'id': '4',
    'name': 'Audi A6',
    'brand': 'Audi',
    'year': '2022',
    'category': 'Luxury',
    'price': 130,
    'rating': 4.6,
    'seats': 5,
    'transmission': 'Auto',
    'fuel': 'Petrol',
    'range': '380 mi',
    'color': 0xFF37474F,
    'desc': 'The Audi A6 is a sophisticated executive sedan with cutting-edge technology and a refined interior. Ideal for business travel and long journeys.',
  },
  {
    'id': '5',
    'name': 'Porsche 911',
    'brand': 'Porsche',
    'year': '2023',
    'category': 'Sports',
    'price': 200,
    'rating': 5.0,
    'seats': 2,
    'transmission': 'Manual',
    'fuel': 'Petrol',
    'range': '290 mi',
    'color': 0xFF4E342E,
    'desc': 'The Porsche 911 is an iconic sports car with rear-engine layout and exceptional handling. A dream driving experience on Rwanda\'s scenic roads.',
  },
  {
    'id': '6',
    'name': 'Mercedes GLE',
    'brand': 'Mercedes',
    'year': '2022',
    'category': 'SUV',
    'price': 160,
    'rating': 4.8,
    'seats': 7,
    'transmission': 'Auto',
    'fuel': 'Diesel',
    'range': '360 mi',
    'color': 0xFF263238,
    'desc': 'The Mercedes-Benz GLE is a premium SUV with spacious interior and advanced driver assistance systems. Comfort and capability in one package.',
  },
  {
    'id': '7',
    'name': 'Toyota RAV4',
    'brand': 'Toyota',
    'year': '2022',
    'category': 'SUV',
    'price': 60,
    'rating': 4.7,
    'seats': 5,
    'transmission': 'Auto',
    'fuel': 'Petrol',
    'range': '400 mi',
    'color': 0xFF1B5E20,
    'desc': 'The Toyota RAV4 is a reliable and versatile compact SUV. Popular across Rwanda for its durability, fuel efficiency, and all-terrain capability.',
  },
  {
    'id': '8',
    'name': 'Toyota Camry',
    'brand': 'Toyota',
    'year': '2021',
    'category': 'Economy',
    'price': 45,
    'rating': 4.6,
    'seats': 5,
    'transmission': 'Auto',
    'fuel': 'Petrol',
    'range': '450 mi',
    'color': 0xFF1A237E,
    'desc': 'The Toyota Camry is a dependable mid-size sedan known for comfort and reliability. Great value for money with low running costs.',
  },
];
