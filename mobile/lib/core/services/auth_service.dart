import 'package:dartz/dartz.dart';
import 'package:mobile/core/error/failure.dart';
import 'package:mobile/core/injection_container.dart';
import 'package:mobile/core/services/dynamic_theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/Authentication/domain/entities/user.dart';
import 'package:mobile/features/Authentication/domain/repositories/login_repository.dart';

class AuthService {
  final LoginRepository _loginRepository;
  User? _currentUser;
  bool _isInitialized = false;

  AuthService(this._loginRepository);

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isInitialized => _isInitialized;

  /// Initialize authentication state by checking for existing user
  Future<void> initialize() async {
    if (_isInitialized) return;

    final result = await _loginRepository.getCurrentUser();
    result.fold(
      (failure) {
        _currentUser = null;
        _isInitialized = true;
      },
      (user) {
        _currentUser = user;
        _isInitialized = true;
      },
    );
  }

  /// Login user and update authentication state
  Future<Either<Failure, User>> login(String email, String password) async {
    final result = await _loginRepository.login(email, password);
    result.fold((failure) => null, (user) {
      _currentUser = user;
      // Persist user to SharedPreferences as an additional safeguard
      try {
        final prefs = sl<SharedPreferences>();
        prefs.setString('user_data', user.toJsonString());
      } catch (_) {}
      // Refresh theme after login
      sl<DynamicThemeService>().refreshTheme();
    });
    return result;
  }

  /// Logout user and clear authentication state
  Future<Either<Failure, void>> logout() async {
    final result = await _loginRepository.logout();
    result.fold((failure) => null, (_) {
      _currentUser = null;
      // Also clear persisted tokens/user when possible
      try {
        final prefs = sl<SharedPreferences>();
        prefs.remove('user_data');
      } catch (_) {}
      // Refresh theme after logout
      sl<DynamicThemeService>().refreshTheme();
    });
    return result;
  }

  /// Clear authentication state (for logout)
  void clearAuth() {
    _currentUser = null;
  }

  /// Update current user's joined verse list in memory and persist if needed
  void addJoinedVerse(String verseId) {
    if (_currentUser == null) return;
    if (!_currentUser!.joinedVerse.contains(verseId)) {
      _currentUser!.joinedVerse.add(verseId);
      // Persist updated user so refresh keeps the state
      try {
        final prefs = sl<SharedPreferences>();
        prefs.setString('user_data', _currentUser!.toJsonString());
      } catch (_) {}
      // Inform theme service that verse context changed
      sl<DynamicThemeService>().refreshTheme();
    }
  }
}
