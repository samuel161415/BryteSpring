import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/dashboard/domain/entities/dashboard_entity.dart';

abstract class DashboardLocalDataSource {
  Future<void> cacheDashboardData(String verseId, DashboardEntity dashboardData);
  Future<DashboardEntity?> getCachedDashboardData(String verseId);
  Future<void> clearCachedDashboardData(String verseId);
  Future<void> clearAllCachedDashboardData();
  Future<bool> hasValidCachedData(String verseId);
}

class DashboardLocalDataSourceImpl implements DashboardLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _dashboardCacheKey = 'dashboard_cache';
  static const String _dashboardTimestampKey = 'dashboard_timestamp';
  static const Duration _cacheExpiration = Duration(hours: 1); // Cache expires after 1 hour

  DashboardLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheDashboardData(String verseId, DashboardEntity dashboardData) async {
    try {
      final cacheKey = '${_dashboardCacheKey}_$verseId';
      final timestampKey = '${_dashboardTimestampKey}_$verseId';
      
      // Convert dashboard data to JSON
      final jsonString = jsonEncode(dashboardData.toJson());
      
      // Store dashboard data and timestamp
      await sharedPreferences.setString(cacheKey, jsonString);
      await sharedPreferences.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
      
      print('Dashboard data cached for verse: $verseId');
    } catch (e) {
      print('Error caching dashboard data: $e');
      throw Exception('Failed to cache dashboard data: $e');
    }
  }

  @override
  Future<DashboardEntity?> getCachedDashboardData(String verseId) async {
    try {
      final cacheKey = '${_dashboardCacheKey}_$verseId';
      final timestampKey = '${_dashboardTimestampKey}_$verseId';
      
      // Check if cached data exists
      final cachedJson = sharedPreferences.getString(cacheKey);
      final timestamp = sharedPreferences.getInt(timestampKey);
      
      if (cachedJson == null || timestamp == null) {
        print('No cached dashboard data found for verse: $verseId');
        return null;
      }
      
      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime) > _cacheExpiration) {
        print('Cached dashboard data expired for verse: $verseId');
        await clearCachedDashboardData(verseId);
        return null;
      }
      
      // Parse and return cached data
      final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
      final dashboardData = DashboardEntity.fromJson(jsonMap);
      
      print('Retrieved cached dashboard data for verse: $verseId');
      return dashboardData;
    } catch (e) {
      print('Error retrieving cached dashboard data: $e');
      return null;
    }
  }

  @override
  Future<void> clearCachedDashboardData(String verseId) async {
    try {
      final cacheKey = '${_dashboardCacheKey}_$verseId';
      final timestampKey = '${_dashboardTimestampKey}_$verseId';
      
      await sharedPreferences.remove(cacheKey);
      await sharedPreferences.remove(timestampKey);
      
      print('Cleared cached dashboard data for verse: $verseId');
    } catch (e) {
      print('Error clearing cached dashboard data: $e');
      throw Exception('Failed to clear cached dashboard data: $e');
    }
  }

  @override
  Future<void> clearAllCachedDashboardData() async {
    try {
      final keys = sharedPreferences.getKeys();
      final dashboardKeys = keys.where((key) => 
        key.startsWith(_dashboardCacheKey) || key.startsWith(_dashboardTimestampKey)
      );
      
      for (final key in dashboardKeys) {
        await sharedPreferences.remove(key);
      }
      
      print('Cleared all cached dashboard data');
    } catch (e) {
      print('Error clearing all cached dashboard data: $e');
      throw Exception('Failed to clear all cached dashboard data: $e');
    }
  }

  /// Check if cached data exists and is not expired
  Future<bool> hasValidCachedData(String verseId) async {
    try {
      final timestampKey = '${_dashboardTimestampKey}_$verseId';
      final timestamp = sharedPreferences.getInt(timestampKey);
      
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) <= _cacheExpiration;
    } catch (e) {
      print('Error checking cached data validity: $e');
      return false;
    }
  }
}
