import 'package:flutter/material.dart';
import 'package:mobile/core/constant.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/core/services/auth_service.dart';
import 'package:mobile/features/verse_join/domain/usecases/verse_join_usecase.dart';
import 'package:mobile/features/verse_join/domain/entities/verse_join_entity.dart';

/// Service for managing dynamic theme colors based on user's joined verse
class DynamicThemeService extends ChangeNotifier {
  static final DynamicThemeService _instance = DynamicThemeService._internal();
  factory DynamicThemeService() => _instance;
  DynamicThemeService._internal();

  VerseJoinEntity? _currentVerse;
  Color? _verseSurfaceColor;
  bool _isInitialized = false;

  VerseJoinEntity? get currentVerse => _currentVerse;
  Color? get verseSurfaceColor => _verseSurfaceColor;
  bool get isInitialized => _isInitialized;

  /// Initialize the dynamic theme service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final authService = sl<AuthService>();
      final verseJoinUseCase = sl<VerseJoinUseCase>();

      // Check if user is authenticated and has joined verses
      if (authService.isAuthenticated && authService.currentUser != null) {
        final user = authService.currentUser!;

        if (user.joinedVerse.isNotEmpty) {
          // Get the first joined verse (primary verse) - index 0 as requested
          final verseId = user.joinedVerse.first;
          print('DynamicThemeService: Loading verse for theme - ID: $verseId');

          final verseResult = await verseJoinUseCase.getVerse(verseId);

          verseResult.fold(
            (failure) {
              print('Failed to load verse for theme: $failure');
              _setDefaultTheme();
            },
            (verse) {
              print(
                'DynamicThemeService: Successfully loaded verse: ${verse.name}',
              );
              _currentVerse = verse;
              _updateThemeFromVerse(verse);
            },
          );
        } else {
          print('DynamicThemeService: No joined verses found');
          _setDefaultTheme();
        }
      } else {
        print('DynamicThemeService: User not authenticated');
        _setDefaultTheme();
      }
    } catch (e) {
      print('Error initializing dynamic theme: $e');
      _setDefaultTheme();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Update theme based on verse branding
  void _updateThemeFromVerse(VerseJoinEntity verse) {
    try {
      // Extract primary color from verse branding
      final primaryColorHex = verse.branding.primaryColor;
      if (primaryColorHex.isNotEmpty) {
        // Parse hex color and create a darker surface color
        final primaryColor = _parseHexColor(primaryColorHex);
        _verseSurfaceColor = _createSurfaceColor(primaryColor);

        // Update the global theme
        _updateGlobalTheme(primaryColor, _verseSurfaceColor!);

        print('Dynamic theme updated for verse: ${verse.name}');
        print('Primary color: $primaryColorHex');
        print('Surface color: ${_verseSurfaceColor!.toHex()}');
      } else {
        _setDefaultTheme();
      }
    } catch (e) {
      print('Error updating theme from verse: $e');
      _setDefaultTheme();
    }
  }

  /// Set default theme (black surface)
  void _setDefaultTheme() {
    _currentVerse = null;
    _verseSurfaceColor = null;

    // Set default black theme
    AppTheme.setTheme('default');
    print('Dynamic theme set to default (black)');
  }

  /// Update global theme with verse colors
  void _updateGlobalTheme(Color primaryColor, Color surfaceColor) {
    AppTheme.currentTheme = {
      'name': 'dynamic_verse',
      'colors': {
        'primary': primaryColor,
        'secondary': primaryColor.withOpacity(0.7),
        'background': const Color(0xFF0D1117), // Keep dark background
        'surface': surfaceColor,
        'text': Colors.white,
        'textSecondary': Colors.white.withOpacity(0.7),
        'error': const Color(0xFFB00020),
        'success': const Color(0xFF238636),
        'border': surfaceColor.withOpacity(0.3),
      },
    };
  }

  /// Create a darker surface color from primary color
  Color _createSurfaceColor(Color primaryColor) {
    // Convert primary color to HSL and darken it
    final hsl = HSLColor.fromColor(primaryColor);
    final darkenedHsl = hsl.withLightness(0.15); // Very dark
    return darkenedHsl.toColor();
  }

  /// Parse hex color string to Color object
  Color _parseHexColor(String hexColor) {
    // Remove # if present
    String cleanHex = hexColor.replaceAll('#', '');

    // Ensure it's 6 characters
    if (cleanHex.length == 3) {
      cleanHex = cleanHex.split('').map((char) => char + char).join('');
    }

    // Add alpha if not present
    if (cleanHex.length == 6) {
      cleanHex = 'FF$cleanHex';
    }

    return Color(int.parse(cleanHex, radix: 16));
  }

  /// Force refresh theme (useful after login/logout)
  Future<void> refreshTheme() async {
    _isInitialized = false;
    await initialize();
  }

  /// Check if user has joined verses
  bool get hasJoinedVerse {
    final authService = sl<AuthService>();
    return authService.isAuthenticated &&
        authService.currentUser != null &&
        authService.currentUser!.joinedVerse.isNotEmpty;
  }

  /// Get current surface color (verse-based or default)
  Color getCurrentSurfaceColor() {
    if (hasJoinedVerse && _verseSurfaceColor != null) {
      return _verseSurfaceColor!;
    }
    return const Color(0xFF161B22); // Default black surface
  }
}

/// Extension to convert Color to hex string
extension ColorExtension on Color {
  String toHex() {
    return '#${value.toRadixString(16).substring(2).toUpperCase()}';
  }
}
