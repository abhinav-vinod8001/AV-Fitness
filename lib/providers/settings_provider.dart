import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsState {
  final ThemeMode themeMode;
  final Color seedColor;
  final String weightUnit;
  final String groqApiKey;

  const SettingsState({
    this.themeMode = ThemeMode.dark,
    this.seedColor = AppColors.primary,
    this.weightUnit = 'kg',
    this.groqApiKey = '',
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    String? weightUnit,
    String? groqApiKey,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
      weightUnit: weightUnit ?? this.weightUnit,
      groqApiKey: groqApiKey ?? this.groqApiKey,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('groqApiKey') ?? '';
    final unit = prefs.getString('weightUnit') ?? 'kg';
    final themeStr = prefs.getString('themeMode');
    final colorVal = prefs.getInt('seedColor');

    ThemeMode mode = ThemeMode.dark;
    if (themeStr == 'light') mode = ThemeMode.light;
    if (themeStr == 'system') mode = ThemeMode.system;

    Color seedColor = AppColors.primary;
    if (colorVal != null) {
      seedColor = Color(colorVal);
    }

    state = state.copyWith(
      groqApiKey: apiKey,
      weightUnit: unit,
      themeMode: mode,
      seedColor: seedColor,
    );
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.name);
  }

  Future<void> updateSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('seedColor', color.toARGB32());
  }

  Future<void> updateWeightUnit(String unit) async {
    state = state.copyWith(weightUnit: unit);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weightUnit', unit);
  }
  
  Future<void> updateGroqApiKey(String apiKey) async {
    final cleaned = apiKey.trim().replaceAll('"', '').replaceAll("'", '');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('groqApiKey', cleaned);
    state = state.copyWith(groqApiKey: cleaned);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
