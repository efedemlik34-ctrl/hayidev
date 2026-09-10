import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FeedbackService {
  static bool _soundOn = true;
  static bool _hapticOn = true;

  static bool get soundOn => _soundOn;
  static bool get hapticOn => _hapticOn;

  static Future<void> init() async {
    final p = await SharedPreferences.getInstance();
    _soundOn = p.getBool('sound_on') ?? true;
    _hapticOn = p.getBool('haptic_on') ?? true;
  }

  static Future<void> toggleSound() async {
    _soundOn = !_soundOn;
    final p = await SharedPreferences.getInstance();
    await p.setBool('sound_on', _soundOn);
  }

  static Future<void> toggleHaptic() async {
    _hapticOn = !_hapticOn;
    final p = await SharedPreferences.getInstance();
    await p.setBool('haptic_on', _hapticOn);
  }

  static Future<void> tap() async {
    if (_hapticOn) await HapticFeedback.selectionClick();
  }

  static Future<void> light() async {
    if (_hapticOn) await HapticFeedback.lightImpact();
  }

  static Future<void> medium() async {
    if (_hapticOn) await HapticFeedback.mediumImpact();
  }

  static Future<void> heavy() async {
    if (_hapticOn) await HapticFeedback.heavyImpact();
  }

  static Future<void> success() async {
    if (_hapticOn) {
      await HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 80));
      await HapticFeedback.lightImpact();
    }
  }

  static Future<void> error() async {
    if (_hapticOn) {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 60));
      await HapticFeedback.heavyImpact();
    }
  }

  static Future<void> jackpot() async {
    if (_hapticOn) {
      for (var i = 0; i < 5; i++) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 50));
      }
    }
  }
}
