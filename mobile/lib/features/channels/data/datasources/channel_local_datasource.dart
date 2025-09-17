import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile/features/channels/domain/entities/channel_entity.dart';

abstract class ChannelLocalDataSource {
  Future<void> cacheChannelStructure(String verseId, ChannelStructureResponse channelStructure);
  Future<ChannelStructureResponse?> getCachedChannelStructure(String verseId);
  Future<void> cacheChannelContents(String channelId, ChannelEntity channelContents);
  Future<ChannelEntity?> getCachedChannelContents(String channelId);
  Future<void> clearCachedChannelStructure(String verseId);
  Future<void> clearCachedChannelContents(String channelId);
  Future<void> clearAllCachedChannelData();
  Future<bool> hasValidCachedChannelStructure(String verseId);
  Future<bool> hasValidCachedChannelContents(String channelId);
}

class ChannelLocalDataSourceImpl implements ChannelLocalDataSource {
  final SharedPreferences sharedPreferences;
  
  static const String _channelStructureCacheKey = 'channel_structure_cache';
  static const String _channelStructureTimestampKey = 'channel_structure_timestamp';
  static const String _channelContentsCacheKey = 'channel_contents_cache';
  static const String _channelContentsTimestampKey = 'channel_contents_timestamp';
  static const Duration _cacheExpiration = Duration(hours: 2); // Cache expires after 2 hours

  ChannelLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheChannelStructure(String verseId, ChannelStructureResponse channelStructure) async {
    try {
      final cacheKey = '${_channelStructureCacheKey}_$verseId';
      final timestampKey = '${_channelStructureTimestampKey}_$verseId';
      
      // Convert channel structure to JSON
      final jsonString = jsonEncode(channelStructure.toJson());
      
      // Store channel structure and timestamp
      await sharedPreferences.setString(cacheKey, jsonString);
      await sharedPreferences.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
      
      print('Channel structure cached for verse: $verseId');
    } catch (e) {
      print('Error caching channel structure: $e');
      throw Exception('Failed to cache channel structure: $e');
    }
  }

  @override
  Future<ChannelStructureResponse?> getCachedChannelStructure(String verseId) async {
    try {
      final cacheKey = '${_channelStructureCacheKey}_$verseId';
      final timestampKey = '${_channelStructureTimestampKey}_$verseId';
      
      // Check if cached data exists
      final cachedJson = sharedPreferences.getString(cacheKey);
      final timestamp = sharedPreferences.getInt(timestampKey);
      
      if (cachedJson == null || timestamp == null) {
        print('No cached channel structure found for verse: $verseId');
        return null;
      }
      
      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime) > _cacheExpiration) {
        print('Cached channel structure expired for verse: $verseId');
        await clearCachedChannelStructure(verseId);
        return null;
      }
      
      // Parse and return cached data
      final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
      final channelStructure = ChannelStructureResponse.fromJson(jsonMap);
      
      print('Retrieved cached channel structure for verse: $verseId');
      return channelStructure;
    } catch (e) {
      print('Error retrieving cached channel structure: $e');
      return null;
    }
  }

  @override
  Future<void> cacheChannelContents(String channelId, ChannelEntity channelContents) async {
    try {
      final cacheKey = '${_channelContentsCacheKey}_$channelId';
      final timestampKey = '${_channelContentsTimestampKey}_$channelId';
      
      // Convert channel contents to JSON
      final jsonString = jsonEncode(channelContents.toJson());
      
      // Store channel contents and timestamp
      await sharedPreferences.setString(cacheKey, jsonString);
      await sharedPreferences.setInt(timestampKey, DateTime.now().millisecondsSinceEpoch);
      
      print('Channel contents cached for channel: $channelId');
    } catch (e) {
      print('Error caching channel contents: $e');
      throw Exception('Failed to cache channel contents: $e');
    }
  }

  @override
  Future<ChannelEntity?> getCachedChannelContents(String channelId) async {
    try {
      final cacheKey = '${_channelContentsCacheKey}_$channelId';
      final timestampKey = '${_channelContentsTimestampKey}_$channelId';
      
      // Check if cached data exists
      final cachedJson = sharedPreferences.getString(cacheKey);
      final timestamp = sharedPreferences.getInt(timestampKey);
      
      if (cachedJson == null || timestamp == null) {
        print('No cached channel contents found for channel: $channelId');
        return null;
      }
      
      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      if (now.difference(cacheTime) > _cacheExpiration) {
        print('Cached channel contents expired for channel: $channelId');
        await clearCachedChannelContents(channelId);
        return null;
      }
      
      // Parse and return cached data
      final jsonMap = jsonDecode(cachedJson) as Map<String, dynamic>;
      final channelContents = ChannelEntity.fromJson(jsonMap);
      
      print('Retrieved cached channel contents for channel: $channelId');
      return channelContents;
    } catch (e) {
      print('Error retrieving cached channel contents: $e');
      return null;
    }
  }

  @override
  Future<void> clearCachedChannelStructure(String verseId) async {
    try {
      final cacheKey = '${_channelStructureCacheKey}_$verseId';
      final timestampKey = '${_channelStructureTimestampKey}_$verseId';
      
      await sharedPreferences.remove(cacheKey);
      await sharedPreferences.remove(timestampKey);
      
      print('Cleared cached channel structure for verse: $verseId');
    } catch (e) {
      print('Error clearing cached channel structure: $e');
      throw Exception('Failed to clear cached channel structure: $e');
    }
  }

  @override
  Future<void> clearCachedChannelContents(String channelId) async {
    try {
      final cacheKey = '${_channelContentsCacheKey}_$channelId';
      final timestampKey = '${_channelContentsTimestampKey}_$channelId';
      
      await sharedPreferences.remove(cacheKey);
      await sharedPreferences.remove(timestampKey);
      
      print('Cleared cached channel contents for channel: $channelId');
    } catch (e) {
      print('Error clearing cached channel contents: $e');
      throw Exception('Failed to clear cached channel contents: $e');
    }
  }

  @override
  Future<void> clearAllCachedChannelData() async {
    try {
      final keys = sharedPreferences.getKeys();
      final channelKeys = keys.where((key) => 
        key.startsWith(_channelStructureCacheKey) || 
        key.startsWith(_channelStructureTimestampKey) ||
        key.startsWith(_channelContentsCacheKey) ||
        key.startsWith(_channelContentsTimestampKey)
      );
      
      for (final key in channelKeys) {
        await sharedPreferences.remove(key);
      }
      
      print('Cleared all cached channel data');
    } catch (e) {
      print('Error clearing all cached channel data: $e');
      throw Exception('Failed to clear all cached channel data: $e');
    }
  }

  @override
  Future<bool> hasValidCachedChannelStructure(String verseId) async {
    try {
      final timestampKey = '${_channelStructureTimestampKey}_$verseId';
      final timestamp = sharedPreferences.getInt(timestampKey);
      
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) <= _cacheExpiration;
    } catch (e) {
      print('Error checking cached channel structure validity: $e');
      return false;
    }
  }

  @override
  Future<bool> hasValidCachedChannelContents(String channelId) async {
    try {
      final timestampKey = '${_channelContentsTimestampKey}_$channelId';
      final timestamp = sharedPreferences.getInt(timestampKey);
      
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      
      return now.difference(cacheTime) <= _cacheExpiration;
    } catch (e) {
      print('Error checking cached channel contents validity: $e');
      return false;
    }
  }
}
