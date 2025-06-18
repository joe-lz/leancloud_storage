part of leancloud_storage;

/// Specifies interaction with the cached responses.
enum CachePolicy {
  /// Always queries from the cloud.
  onlyNetwork,

  /// Queries from the cloud first,
  /// if failed, it will queries from the cache instead.
  networkElseCache,

  /// Always queries from the cache only.
  onlyCache,

  /// Queries from the cache first,
  /// if cache miss, it will queries from the cloud.
  cacheElseNetwork,

  /// Queries from cache if available and not expired,
  /// otherwise queries from the cloud.
  cacheFirst,

  /// Queries from both cache and network,
  /// returns cache immediately and updates with network response.
  cacheAndNetwork
}

class LCQueryCache {
  static const String _cacheKeyPrefix = 'lc_query_cache_';
  static const int _defaultExpirationTime = 300; // 5 minutes in seconds默认的5分钟缓存时间

  final Map<String, CachedQuery> _memoryCache = {};

  LCQueryCache();

  /// Check if cache exists for the given key
  bool hasCachedResult(String cacheKey) {
    final cached = _memoryCache[cacheKey];
    if (cached == null) return false;

    // Check if expired
    if (cached.isExpired()) {
      _memoryCache.remove(cacheKey);
      return false;
    }

    return true;
  }

  /// Get cached result for the given key
  dynamic getCachedResult(String cacheKey) {
    final cached = _memoryCache[cacheKey];
    if (cached == null || cached.isExpired()) {
      _memoryCache.remove(cacheKey);
      return null;
    }

    return cached.data;
  }

  /// Cache the query result
  void cacheResult(String cacheKey, dynamic data, {int? ttlSeconds}) {
    final ttl = ttlSeconds ?? _defaultExpirationTime;
    final expiration = DateTime.now().add(Duration(seconds: ttl));

    _memoryCache[cacheKey] = CachedQuery(
      data: data,
      expiration: expiration,
    );
  }

  /// Clear specific cache entry
  void clearCache(String cacheKey) {
    _memoryCache.remove(cacheKey);
  }

  /// Clear all cached entries
  void clearAllCache() {
    _memoryCache.clear();
  }

  /// Generate cache key from query parameters
  String generateCacheKey(String className, Map<String, dynamic> queryParams) {
    final sortedParams = Map.fromEntries(queryParams.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    final paramString = sortedParams.toString();
    return '$_cacheKeyPrefix${className}_${paramString.hashCode}';
  }
}

/// Represents a cached query result
class CachedQuery {
  final dynamic data;
  final DateTime expiration;

  CachedQuery({
    required this.data,
    required this.expiration,
  });

  /// Check if the cached data has expired
  bool isExpired() {
    return DateTime.now().isAfter(expiration);
  }
}
