import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import 'package:mobile/features/auth/auth_service.dart';
import 'package:mobile/features/grammar/grammar_ai_service.dart';
import 'package:mobile/features/games/mini_game_screen.dart';
import 'package:mobile/core/services/progress_service.dart';

part 'app/app_shell.dart';
part 'app/shared_widgets.dart';
part 'app/visual_helpers.dart';
part 'core/models/app_models.dart';
part 'core/services/learning_progress_store.dart';
part 'features/auth/auth_flow.dart';
part 'features/home/home_screen.dart';
part 'features/profile/profile_repository.dart';
part 'features/profile/profile_screen.dart';
part 'features/vocabulary/vocabulary_screen.dart';
part 'features/vocabulary/dictionary_repository.dart';
part 'features/vocabulary/flashcard_lesson_screen.dart';
part 'features/vocabulary/flashcard_cards.dart';
part 'features/vocabulary/flashcard_view.dart';
part 'features/vocabulary/flashcard_repository.dart';
part 'features/grammar/grammar_screen.dart';
part 'features/grammar/grammar_cards.dart';
part 'features/grammar/grammar_repository.dart';
part 'features/grammar/grammar_checker.dart';
part 'features/reading/reading_practice_screen.dart';
part 'features/reading/reading_repository.dart';
part 'features/reading/pronunciation_practice_sheet.dart';
part 'features/reading/video_lesson_detail_screen.dart';
part 'features/reading/video_lesson_card.dart';
part 'features/reading/video_repository.dart';
part 'features/reading/video_learning_controller.dart';

void main() {
  runApp(const VNChineseApp());
}

class AppColors {
  static const ink = Color(0xFF151922);
  static const muted = Color(0xFF596275);
  static const paper = Color(0xFFFAF7F2);
  static const surface = Color(0xFFFFFFFF);
  static const line = Color(0xFFE4D9CC);
  static const cinnabar = Color(0xFFC83E35);
  static const jade = Color(0xFF197A62);
  static const amber = Color(0xFFE0A326);
  static const blue = Color(0xFF2563A9);
  static const plum = Color(0xFF7E4C8B);
}

class VNChineseApp extends StatelessWidget {
  const VNChineseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VNChinese',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        fontFamilyFallback: const ['Roboto', 'Arial', 'NotoSansSC'],
        visualDensity: VisualDensity.standard,
        scaffoldBackgroundColor: AppColors.paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.cinnabar,
          primary: AppColors.cinnabar,
          secondary: AppColors.jade,
          surface: AppColors.surface,
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            height: 1.14,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          headlineMedium: TextStyle(
            fontSize: 25,
            height: 1.22,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            height: 1.28,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
          bodyLarge: TextStyle(
            fontSize: 15.5,
            height: 1.55,
            color: AppColors.ink,
          ),
          bodyMedium: TextStyle(
            fontSize: 14.5,
            height: 1.55,
            color: AppColors.muted,
          ),
          labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: AppColors.paper,
          foregroundColor: AppColors.ink,
          titleTextStyle: TextStyle(
            color: AppColors.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.25,
          ),
        ),
        navigationBarTheme: NavigationBarThemeData(
          height: 74,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.cinnabar.withValues(alpha: 0.12),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return IconThemeData(
              color: selected ? AppColors.ink : AppColors.muted,
              size: selected ? 25 : 23,
            );
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            final selected = states.contains(WidgetState.selected);
            return TextStyle(
              color: selected ? AppColors.ink : AppColors.muted,
              fontSize: 12,
              height: 1.15,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            );
          }),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.cinnabar, width: 1.4),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.cinnabar,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.ink,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            side: const BorderSide(color: AppColors.line),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}
