part of leancloud_storage;

/// A query to fetch [LCObject].
class LCQuery<T extends LCObject> {
  /// Which [className] to query.
  String? className;

  Duration? maxCacheAge;

  late _LCCompositionalCondition condition;

  /// Creates a new query for [className].
  LCQuery(this.className) {
    condition = new _LCCompositionalCondition();
  }

  LCQuery<T> whereEqualTo(String key, dynamic value) {
    condition.whereEqualTo(key, value);
    return this;
  }

  LCQuery<T> whereNotEqualTo(String key, dynamic value) {
    condition.whereNotEqualTo(key, value);
    return this;
  }

  /// The value of [key] must be contained in [values].
  LCQuery<T> whereContainedIn(String key, Iterable values) {
    condition.whereContainedIn(key, values);
    return this;
  }

  /// The value of [key] must not be contained in [values].
  LCQuery<T> whereNotContainedIn(String key, Iterable values) {
    condition.whereNotContainedIn(key, values);
    return this;
  }

  /// The array [key] must contain all [values].
  LCQuery<T> whereContainsAll(String key, Iterable values) {
    condition.whereContainsAll(key, values);
    return this;
  }

  /// The [LCObject] must contain the given [key].
  LCQuery<T> whereExists(String key) {
    condition.whereExists(key);
    return this;
  }

  /// The [LCObject] must not contain the given [key].
  LCQuery<T> whereDoesNotExist(String key) {
    condition.whereDoesNotExist(key);
    return this;
  }

  LCQuery<T> whereSizeEqualTo(String key, int size) {
    condition.whereSizeEqualTo(key, size);
    return this;
  }

  LCQuery<T> whereGreaterThan(String key, dynamic value) {
    condition.whereGreaterThan(key, value);
    return this;
  }

  LCQuery<T> whereGreaterThanOrEqualTo(String key, dynamic value) {
    condition.whereGreaterThanOrEqualTo(key, value);
    return this;
  }

  LCQuery<T> whereLessThan(String key, dynamic value) {
    condition.whereLessThan(key, value);
    return this;
  }

  LCQuery<T> whereLessThanOrEqualTo(String key, dynamic value) {
    condition.whereLessThanOrEqualTo(key, value);
    return this;
  }

  LCQuery<T> whereNear(String key, LCGeoPoint point) {
    condition.whereNear(key, point);
    return this;
  }

  LCQuery<T> whereWithinGeoBox(String key, LCGeoPoint southwest, LCGeoPoint northeast) {
    condition.whereWithinGeoBox(key, southwest, northeast);
    return this;
  }

  LCQuery<T> whereWithinRadians(String key, LCGeoPoint point, double maxDistance) {
    condition.whereWithinRadians(key, point, maxDistance);
    return this;
  }

  LCQuery<T> whereWithinMiles(String key, LCGeoPoint point, double maxDistance) {
    return whereWithinRadians(key, point, maxDistance / 3958.8);
  }

  LCQuery<T> whereWithinKilometers(String key, LCGeoPoint point, double maxDistance) {
    return whereWithinRadians(key, point, maxDistance / 6371.0);
  }

  LCQuery<T> whereRelatedTo(LCObject parent, String key) {
    condition.whereRelatedTo(parent, key);
    return this;
  }

  LCQuery<T> whereStartsWith(String key, String prefix) {
    condition.whereStartsWith(key, prefix);
    return this;
  }

  LCQuery<T> whereEndsWith(String key, String suffix) {
    condition.whereEndsWith(key, suffix);
    return this;
  }

  LCQuery<T> whereContains(String key, String subString) {
    condition.whereContains(key, subString);
    return this;
  }

  LCQuery<T> whereMatches(String key, String regex, {String? modifiers}) {
    condition.whereMatches(key, regex, modifiers);
    return this;
  }

  /// The value of [key] must match [query].
  LCQuery<T> whereMatchesQuery(String key, LCQuery query) {
    condition.whereMatchesQuery(key, query);
    return this;
  }

  /// The value of [key] must not match [query].
  LCQuery<T> whereDoesNotMatchQuery(String key, LCQuery query) {
    condition.whereDoesNotMatchQuery(key, query);
    return this;
  }

  LCQuery<T> orderByAscending(String key) {
    condition.orderByAscending(key);
    return this;
  }

  LCQuery<T> orderByDescending(String key) {
    condition.orderByDecending(key);
    return this;
  }

  /// Also sorts the results in ascending order by the given [key].
  ///
  /// The previous sort keys have precedence over this [key].
  LCQuery<T> addAscendingOrder(String key) {
    condition.addAscendingOrder(key);
    return this;
  }

  /// Also sorts the results in descending order by the given [key].
  ///
  /// The previous sort keys have precedence over this [key].
  LCQuery<T> addDescendingOrder(String key) {
    condition.addDescendingOrder(key);
    return this;
  }

  /// Includes nested [LCObject] for the provided [key].
  LCQuery<T> include(String key) {
    condition.include(key);
    return this;
  }

  /// Restricts the [keys] of the [LCObject] returned.
  LCQuery<T> select(String keys) {
    condition.select(keys);
    return this;
  }

  /// Includes the ALC or not.
  LCQuery<T> includeACL(bool value) {
    condition.includeACL = value;
    return this;
  }

  /// Sets the [amount] of results to skip before returning any results.
  ///
  /// This is useful for pagination.
  /// Default is to skip zero results.
  LCQuery<T> skip(int amount) {
    condition.skip = amount;
    return this;
  }

  /// Sets the limit of the number of results to return.
  ///
  /// The default limit is 100,
  /// with a maximum of 1000 results being returned at a time.
  LCQuery<T> limit(int amount) {
    condition.limit = amount;
    return this;
  }

  /// Counts the number of results.
  Future<int> count() async {
    String path = 'classes/$className';
    Map<String, dynamic> params = _buildParams();
    params['limit'] = 0;
    params['count'] = 1;
    Map result = await LeanCloud._httpClient.get(path, queryParams: params);
    return result['count'];
  }

  /// Constructs a [LCObject] whose [objectId] is already known.
  /// Retrieves a single [LCObject] by [objectId], respecting [cachePolicy].
  ///
  /// [objectId] - The objectId of the object to retrieve
  /// [cachePolicy] - The cache policy to use for this query
  /// [cacheTtlSeconds] - Custom cache TTL in seconds. If null, uses default TTL (5 minutes)
  Future<T?> get(
    String objectId, {
    CachePolicy cachePolicy = CachePolicy.onlyNetwork,
    int? cacheTtlSeconds,
  }) async {
    if (isNullOrEmpty(objectId)) {
      throw new ArgumentError.notNull('objectId');
    }

    String path = "classes/$className/$objectId";
    Map<String, dynamic>? queryParams;
    String? includes = condition._buildIncludes();
    if (includes != null) {
      queryParams = {"include": includes};
    }

    // 如果有查询缓存，尝试使用缓存策略
    if (LeanCloud._queryCache != null && cachePolicy != CachePolicy.onlyNetwork) {
      return await _getWithCache(path, queryParams ?? {}, objectId, cachePolicy, cacheTtlSeconds);
    }

    // 默认网络查询
    Map<String, dynamic> response = await LeanCloud._httpClient.get(path, queryParams: queryParams);
    return _decodeLCObject(response);
  }

  Future<T?> _getWithCache(String path, Map<String, dynamic> params, String objectId, CachePolicy cachePolicy, int? cacheTtlSeconds) async {
    final cache = LeanCloud._queryCache!;
    final cacheKey = cache.generateCacheKey(className!, {...params, 'objectId': objectId});

    switch (cachePolicy) {
      case CachePolicy.onlyCache:
        // 仅使用缓存
        final cachedData = cache.getCachedResult(cacheKey);
        if (cachedData != null) {
          return _decodeLCObject(cachedData);
        }
        throw LCException(404, 'No cached data available');

      case CachePolicy.cacheElseNetwork:
        // 优先使用缓存，缓存未命中时查询网络
        if (cache.hasCachedResult(cacheKey)) {
          final cachedData = cache.getCachedResult(cacheKey);
          return _decodeLCObject(cachedData);
        }
        return await _getFromNetworkAndCache(path, params, cacheKey, cache, cacheTtlSeconds);

      case CachePolicy.cacheFirst:
        // 智能缓存优先（考虑过期时间）
        if (cache.hasCachedResult(cacheKey)) {
          final cachedData = cache.getCachedResult(cacheKey);
          return _decodeLCObject(cachedData);
        }
        return await _getFromNetworkAndCache(path, params, cacheKey, cache, cacheTtlSeconds);

      case CachePolicy.networkElseCache:
      default:
        // 网络优先，失败时使用缓存
        return await _getFromNetworkAndCache(path, params, cacheKey, cache, cacheTtlSeconds);
    }
  }

  Future<T?> _getFromNetworkAndCache(String path, Map<String, dynamic> params, String cacheKey, LCQueryCache cache, int? cacheTtlSeconds) async {
    try {
      Map<String, dynamic> response = await LeanCloud._httpClient.get(path, queryParams: params.isNotEmpty ? params : null);

      // 缓存结果，使用自定义TTL
      cache.cacheResult(cacheKey, response, ttlSeconds: cacheTtlSeconds);

      return _decodeLCObject(response);
    } catch (error) {
      // 网络请求失败，尝试使用缓存
      if (cache.hasCachedResult(cacheKey)) {
        final cachedData = cache.getCachedResult(cacheKey);
        return _decodeLCObject(cachedData);
      }
      rethrow;
    }
  }

  /// Retrieves a list of [LCObject]s matching this query, respecting [cachePolicy].
  ///
  /// [cachePolicy] - The cache policy to use for this query
  /// [cacheTtlSeconds] - Custom cache TTL in seconds. If null, uses default TTL (5 minutes)
  Future<List<T>?> find({
    CachePolicy cachePolicy = CachePolicy.onlyNetwork,
    int? cacheTtlSeconds,
  }) async {
    return _fetch(cachePolicy, cacheTtlSeconds);
  }

  Future<List<T>> _fetch(CachePolicy cachePolicy, [int? cacheTtlSeconds]) async {
    String path = 'classes/$className';
    Map<String, dynamic> params = _buildParams();

    // 如果有查询缓存，尝试使用缓存策略
    if (LeanCloud._queryCache != null) {
      return await _fetchWithCache(path, params, cachePolicy, cacheTtlSeconds);
    }

    // 默认网络查询
    Map response = await LeanCloud._httpClient.get(path, queryParams: params, maxCacheAge: maxCacheAge, cachePolicy: cachePolicy);
    List results = response['results'];
    List<T> list = [];
    results.forEach((item) {
      T object = _decodeLCObject(item);
      list.add(object);
    });
    return list;
  }

  Future<List<T>> _fetchWithCache(String path, Map<String, dynamic> params, CachePolicy cachePolicy, [int? cacheTtlSeconds]) async {
    final cache = LeanCloud._queryCache!;
    final cacheKey = cache.generateCacheKey(className!, params);

    switch (cachePolicy) {
      case CachePolicy.onlyCache:
        // 仅使用缓存
        final cachedData = cache.getCachedResult(cacheKey);
        if (cachedData != null) {
          return _parseResultsFromCache(cachedData);
        }
        throw LCException(404, 'No cached data available');

      case CachePolicy.cacheElseNetwork:
        // 优先使用缓存，缓存未命中时查询网络
        if (cache.hasCachedResult(cacheKey)) {
          final cachedData = cache.getCachedResult(cacheKey);
          return _parseResultsFromCache(cachedData);
        }
        // 缓存未命中，查询网络并缓存结果
        return await _fetchFromNetworkAndCache(path, params, cacheKey, cache, cacheTtlSeconds);

      case CachePolicy.cacheFirst:
        // 智能缓存优先（考虑过期时间）
        if (cache.hasCachedResult(cacheKey)) {
          final cachedData = cache.getCachedResult(cacheKey);
          return _parseResultsFromCache(cachedData);
        }
        return await _fetchFromNetworkAndCache(path, params, cacheKey, cache, cacheTtlSeconds);

      case CachePolicy.cacheAndNetwork:
        // 缓存和网络并行
        List<T>? cachedResults;
        if (cache.hasCachedResult(cacheKey)) {
          final cachedData = cache.getCachedResult(cacheKey);
          cachedResults = _parseResultsFromCache(cachedData);
        }

        // 异步更新网络数据
        _fetchFromNetworkAndCache(path, params, cacheKey, cache, cacheTtlSeconds).then((networkResults) {
          // 网络数据获取成功，可以触发回调通知UI更新
        }).catchError((error) {
          // 网络请求失败，但缓存数据仍然有效
        });

        if (cachedResults != null) {
          return cachedResults;
        }
        // 如果没有缓存，等待网络请求
        return await _fetchFromNetworkAndCache(path, params, cacheKey, cache, cacheTtlSeconds);

      default:
        // 默认策略：networkElseCache 或 onlyNetwork
        return await _fetchFromNetworkAndCache(path, params, cacheKey, cache, cacheTtlSeconds);
    }
  }

  Future<List<T>> _fetchFromNetworkAndCache(String path, Map<String, dynamic> params, String cacheKey, LCQueryCache cache, [int? cacheTtlSeconds]) async {
    try {
      Map response = await LeanCloud._httpClient.get(path, queryParams: params, maxCacheAge: maxCacheAge);

      // 缓存结果，使用自定义TTL
      cache.cacheResult(cacheKey, response['results'], ttlSeconds: cacheTtlSeconds);

      List results = response['results'];
      List<T> list = [];
      results.forEach((item) {
        T object = _decodeLCObject(item);
        list.add(object);
      });
      return list;
    } catch (error) {
      // 网络请求失败，尝试使用缓存
      if (cache.hasCachedResult(cacheKey)) {
        final cachedData = cache.getCachedResult(cacheKey);
        return _parseResultsFromCache(cachedData);
      }
      rethrow;
    }
  }

  List<T> _parseResultsFromCache(dynamic cachedData) {
    List results = cachedData as List;
    List<T> list = [];
    results.forEach((item) {
      T object = _decodeLCObject(item);
      list.add(object);
    });
    return list;
  }

  /// Retrieves at most one [LCObject] matching this query.
  ///
  /// [cachePolicy] - The cache policy to use for this query
  /// [cacheTtlSeconds] - Custom cache TTL in seconds. If null, uses default TTL (5 minutes)
  Future<T?> first({
    CachePolicy cachePolicy = CachePolicy.onlyNetwork,
    int? cacheTtlSeconds,
  }) async {
    limit(1);
    List<T>? results = await find(
      cachePolicy: cachePolicy,
      cacheTtlSeconds: cacheTtlSeconds,
    );
    if (results != null && results.length > 0) {
      return results.first;
    }
    return null;
  }

  /// Constructs a [LCQuery] that is the AND of the passed in [queries].
  static LCQuery<T> and<T extends LCObject>(Iterable<LCQuery<T>> queries) {
    LCQuery<T> compositionQuery = new LCQuery<T>(null);
    String? className;
    queries.forEach((item) {
      if (className != null && className != item.className) {
        throw ('All of the queries in an or query must be on the same class.');
      }
      className = item.className;
      compositionQuery.condition.add(item.condition);
    });
    compositionQuery.className = className;
    return compositionQuery;
  }

  /// Constructs a [LCQuery] that is the OR of the passed in [queries].
  static LCQuery<T> or<T extends LCObject>(Iterable<LCQuery<T>> queries) {
    if (queries.length < 1) {
      throw new ArgumentError.notNull('queries');
    }
    LCQuery<T> compositionQuery = new LCQuery<T>(null);
    compositionQuery.condition = new _LCCompositionalCondition(composition: _LCCompositionalCondition.Or);
    String? className;
    queries.forEach((item) {
      if (className != null && className != item.className) {
        throw ('All of the queries in an or query must be on the same class.');
      }
      className = item.className;
      compositionQuery.condition.add(item.condition);
    });
    compositionQuery.className = className;
    return compositionQuery;
  }

  Map<String, dynamic> _buildParams() {
    return condition._buildParams();
  }

  String? _buildWhere() {
    return condition._buildWhere();
  }

  T _decodeLCObject(Map<String, dynamic> data) {
    _LCObjectData objectData = _LCObjectData.decode(data);
    T object = LCObject._create<T>(className!);
    object._merge(objectData);
    return object;
  }
}
