part of leancloud_storage;

/// [LCQuery] of [LCStatus] to find someone's statuses.
class LCStatusQuery extends LCQuery<LCStatus> {
  /// See [LCStatus.inboxType]
  late String inboxType;

  /// Queries [LCStatus] whose messageId is greater than this.
  late int sinceId;

  /// Queries [LCStatus] whose messageId is not greater than this.
  late int maxId;

  /// Constructs a [LCQuery] for [LCStatus].
  LCStatusQuery({String inboxType = LCStatus.InboxTypeDefault}) : super('_Status') {
    this.inboxType = inboxType;
    this.sinceId = 0;
    this.maxId = 0;
  }

  /// See [LCQuery.find].
  @override
  Future<List<LCStatus>?> find({
    CachePolicy cachePolicy = CachePolicy.onlyNetwork,
    int? cacheTtlSeconds,
  }) async {
    LCUser? user = await LCUser.getCurrent();
    if (user == null) {
      throw new ArgumentError.notNull('current user');
    }

    Map<String, dynamic> params = {
      LCStatus.OwnerKey: jsonEncode(_LCEncoder.encode(user)),
      LCStatus.InboxTypeKey: inboxType,
      'where': _buildWhere(),
      'sinceId': sinceId,
      'maxId': maxId,
      'limit': condition.limit
    };
    String? includes = condition._buildIncludes();
    if (includes != null) {
      params['include'] = includes;
    }
    String? keys = condition._buildSelectedKeys();
    if (keys != null) {
      params['keys'] = keys;
    }

    // 如果有查询缓存，尝试使用缓存策略
    if (LeanCloud._queryCache != null && cachePolicy != CachePolicy.onlyNetwork) {
      return await _findWithCache(params, cachePolicy, cacheTtlSeconds);
    }

    // 默认网络查询
    Map response = await LeanCloud._httpClient.get('subscribe/statuses', queryParams: params);
    return _parseStatusResults(response);
  }

  Future<List<LCStatus>> _findWithCache(Map<String, dynamic> params, CachePolicy cachePolicy, int? cacheTtlSeconds) async {
    final cache = LeanCloud._queryCache!;
    final cacheKey = cache.generateCacheKey('_Status', params);

    switch (cachePolicy) {
      case CachePolicy.onlyCache:
        final cachedData = cache.getCachedResult(cacheKey);
        if (cachedData != null) {
          return _parseStatusResultsFromCache(cachedData);
        }
        throw LCException(404, 'No cached data available for status query');

      case CachePolicy.cacheElseNetwork:
        if (cache.hasCachedResult(cacheKey)) {
          final cachedData = cache.getCachedResult(cacheKey);
          return _parseStatusResultsFromCache(cachedData);
        }
        return await _fetchStatusFromNetworkAndCache(params, cacheKey, cache, cacheTtlSeconds);

      case CachePolicy.cacheFirst:
        if (cache.hasCachedResult(cacheKey)) {
          final cachedData = cache.getCachedResult(cacheKey);
          return _parseStatusResultsFromCache(cachedData);
        }
        return await _fetchStatusFromNetworkAndCache(params, cacheKey, cache, cacheTtlSeconds);

      case CachePolicy.networkElseCache:
        try {
          return await _fetchStatusFromNetworkAndCache(params, cacheKey, cache, cacheTtlSeconds);
        } catch (error) {
          if (cache.hasCachedResult(cacheKey)) {
            final cachedData = cache.getCachedResult(cacheKey);
            return _parseStatusResultsFromCache(cachedData);
          }
          rethrow;
        }

      default:
        return await _fetchStatusFromNetworkAndCache(params, cacheKey, cache, cacheTtlSeconds);
    }
  }

  Future<List<LCStatus>> _fetchStatusFromNetworkAndCache(Map<String, dynamic> params, String cacheKey, LCQueryCache cache, int? cacheTtlSeconds) async {
    Map response = await LeanCloud._httpClient.get('subscribe/statuses', queryParams: params);

    // 缓存结果，使用自定义TTL
    cache.cacheResult(cacheKey, response['results'], ttlSeconds: cacheTtlSeconds);

    return _parseStatusResults(response);
  }

  List<LCStatus> _parseStatusResults(Map response) {
    List results = response['results'];
    List<LCStatus> list = [];
    results.forEach((item) {
      _LCObjectData objectData = _LCObjectData.decode(item);
      LCStatus status = new LCStatus();
      status._merge(objectData);
      status.messageId = objectData.customPropertyMap[LCStatus.MessageIdKey];
      status.data = objectData.customPropertyMap;
      status.inboxType = objectData.customPropertyMap[LCStatus.InboxTypeKey];
      list.add(status);
    });
    return list;
  }

  List<LCStatus> _parseStatusResultsFromCache(dynamic cachedData) {
    List results = cachedData as List;
    List<LCStatus> list = [];
    results.forEach((item) {
      _LCObjectData objectData = _LCObjectData.decode(item);
      LCStatus status = new LCStatus();
      status._merge(objectData);
      status.messageId = objectData.customPropertyMap[LCStatus.MessageIdKey];
      status.data = objectData.customPropertyMap;
      status.inboxType = objectData.customPropertyMap[LCStatus.InboxTypeKey];
      list.add(status);
    });
    return list;
  }
}
