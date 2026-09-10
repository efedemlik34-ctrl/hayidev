import 'package:flutter/material.dart';

class GiftItem {
  final String key;
  final String name;
  final String imagePath;
  final int price;
  final String category;
  final bool isJackpot;
  final bool isFree;
  final int tier; // 1-5 (5 = en pahali, animasyonlu)
  const GiftItem({
    required this.key,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.category,
    this.isJackpot = false,
    this.isFree = false,
    this.tier = 1,
  });
}

class GiftCategories {
  static const List<Map<String, String>> categories = [
    {'key': 'hediye',    'name': 'Hediye',       'icon': '🎁'},
    {'key': 'sansli',    'name': 'Sansli',       'icon': '⭐'},
    {'key': 'iliski',    'name': 'Iliski',       'icon': '💕'},
    {'key': 'ulusal',    'name': 'Ulusal',       'icon': '🇹🇷'},
    {'key': 'aristokrasi','name': 'Aristokrasi', 'icon': '👑'},
    {'key': 'ozel',      'name': 'Ozel',         'icon': '✨'},
  ];

  static const List<GiftItem> all = [
    // ═══ HEDIYE ═══
    GiftItem(key: 'kutlama_pasta', name: 'Kutlama Pastasi',
      imagePath: 'assets/games/gifts/kutlama_pasta.png',
      price: 300, category: 'hediye', tier: 1),
    GiftItem(key: 'sansli_yildiz', name: 'Sansli Yildiz',
      imagePath: 'assets/games/gifts/sansli_yildiz.png',
      price: 200, category: 'hediye', isJackpot: true, tier: 1),
    GiftItem(key: 'sansli_can', name: 'Sansli Can',
      imagePath: 'assets/games/gifts/sansli_can.png',
      price: 1000, category: 'hediye', isJackpot: true, tier: 2),
    GiftItem(key: 'sansli_sandik', name: 'Sansli Sandik',
      imagePath: 'assets/games/gifts/sansli_sandik.png',
      price: 100000, category: 'hediye', isJackpot: true, tier: 4),
    GiftItem(key: 'sansli', name: 'Sansli',
      imagePath: 'assets/games/gifts/sansli.png',
      price: 200000, category: 'hediye', isJackpot: true, tier: 5),
    GiftItem(key: 'araba_krali', name: 'Araba Krali',
      imagePath: 'assets/games/gifts/araba_krali.png',
      price: 400000, category: 'hediye', isJackpot: true, tier: 5),
    GiftItem(key: 'lucky_hayi', name: 'Lucky Hayi',
      imagePath: 'assets/games/gifts/lucky_hayi.png',
      price: 2000, category: 'hediye', isJackpot: true, tier: 3),
    GiftItem(key: 'balloon', name: 'Balloon',
      imagePath: 'assets/games/gifts/balloon.png',
      price: 0, category: 'hediye', isFree: true, tier: 1),
    GiftItem(key: 'phoenix_gift', name: 'Anka Kusagi',
      imagePath: 'assets/games/gifts/phoenix_gift.png',
      price: 500000, category: 'hediye', tier: 5),
    GiftItem(key: 'dragon_gift', name: 'Ejderha Hazinesi',
      imagePath: 'assets/games/gifts/dragon_gift.png',
      price: 750000, category: 'hediye', tier: 5),
    GiftItem(key: 'lion_gift', name: 'Aslan Kral',
      imagePath: 'assets/games/gifts/lion_gift.png',
      price: 300000, category: 'hediye', tier: 5),
    GiftItem(key: 'galaxy_gift', name: 'Galaksi Kapisi',
      imagePath: 'assets/games/gifts/galaxy_gift.png',
      price: 1000000, category: 'hediye', tier: 5),

    // ═══ SANSLI ═══
    GiftItem(key: 'lucky_clover', name: 'Sans Yoncasi',
      imagePath: 'assets/games/gifts/lucky_clover.png',
      price: 500, category: 'sansli', tier: 1),
    GiftItem(key: 'lucky_777', name: 'Sansli 777',
      imagePath: 'assets/games/gifts/lucky_777.png',
      price: 70000, category: 'sansli', isJackpot: true, tier: 4),
    GiftItem(key: 'lucky_rainbow', name: 'Gokkusagi',
      imagePath: 'assets/games/gifts/lucky_rainbow.png',
      price: 15000, category: 'sansli', tier: 3),

    // ═══ ILISKI ═══
    GiftItem(key: 'rose', name: 'Gul',
      imagePath: 'assets/games/gifts/rose.png', price: 100, category: 'iliski', tier: 1),
    GiftItem(key: 'heart', name: 'Kalp',
      imagePath: 'assets/games/gifts/heart.png', price: 500, category: 'iliski', tier: 1),
    GiftItem(key: 'teddy', name: 'Ayi',
      imagePath: 'assets/games/gifts/teddy.png', price: 2000, category: 'iliski', tier: 2),
    GiftItem(key: 'ring_gold', name: 'Altin Yuzuk',
      imagePath: 'assets/games/gifts/ring_gold.png',
      price: 100000, category: 'iliski', tier: 4),
    GiftItem(key: 'love_letter', name: 'Ask Mektubu',
      imagePath: 'assets/games/gifts/love_letter.png',
      price: 10000, category: 'iliski', tier: 3),

    // ═══ ULUSAL ═══
    GiftItem(key: 'turk_bayragi', name: 'Turk Bayragi',
      imagePath: 'assets/games/gifts/turk_bayragi.png',
      price: 5000, category: 'ulusal', tier: 2),
    GiftItem(key: 'bozkurt', name: 'Bozkurt',
      imagePath: 'assets/games/gifts/bozkurt.png',
      price: 50000, category: 'ulusal', tier: 4),
    GiftItem(key: 'hilal_yildiz', name: 'Hilal Yildiz',
      imagePath: 'assets/games/gifts/hilal_yildiz.png',
      price: 25000, category: 'ulusal', tier: 3),

    // ═══ ARISTOKRASI ═══
    GiftItem(key: 'crown_gold', name: 'Altin Tac',
      imagePath: 'assets/games/gifts/crown_gold.png',
      price: 250000, category: 'aristokrasi', tier: 5),
    GiftItem(key: 'castle', name: 'Kale',
      imagePath: 'assets/games/gifts/castle.png',
      price: 500000, category: 'aristokrasi', tier: 5),
    GiftItem(key: 'throne', name: 'Taht',
      imagePath: 'assets/games/gifts/throne.png',
      price: 800000, category: 'aristokrasi', tier: 5),
    GiftItem(key: 'king_crown', name: 'Imparator',
      imagePath: 'assets/games/gifts/king_crown.png',
      price: 2000000, category: 'aristokrasi', tier: 5),

    // ═══ OZEL ═══
    GiftItem(key: 'fire_heart', name: 'Alev Kalp',
      imagePath: 'assets/games/gifts/fire_heart.png',
      price: 120000, category: 'ozel', tier: 5),
    GiftItem(key: 'ice_heart', name: 'Buz Kalp',
      imagePath: 'assets/games/gifts/ice_heart.png',
      price: 120000, category: 'ozel', tier: 5),
    GiftItem(key: 'universe', name: 'Evren',
      imagePath: 'assets/games/gifts/universe.png',
      price: 5000000, category: 'ozel', tier: 5),
  ];

  static List<GiftItem> byCategory(String cat) =>
    all.where((g) => g.category == cat).toList();
}
