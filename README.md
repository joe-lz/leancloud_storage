# leancloud_storage

![build](https://img.shields.io/github/workflow/status/leancloud/Storage-SDK-Flutter/Publish%20plugin)
![the latest version](https://img.shields.io/pub/v/leancloud_storage)
![platform](https://img.shields.io/badge/platform-flutter%7Cdart%20vm-ff69b4.svg)

LeanCloud Storage Flutter SDK

## Install

Adding dependency in `pubspec.yaml`:

```dart
dependencies:
  ...
  leancloud_storage: ^0.7.10
```

Then run the following command:

```sh
$ flutter pub get
```

## Import

```dart
import 'package:leancloud_storage/leancloud.dart';
```

## Initialize

```dart
LeanCloud.initialize(
  APP_ID, APP_KEY,
  server: APP_SERVER, // to use your own custom domain
  queryCache: new LCQueryCache() // optional, enable query cache
);
```

## Debug

Enable debug logs:

```dart
LCLogger.setLevel(LCLogger.DebugLevel);
```

## Usage

### Objects

```dart
LCObject object = new LCObject('Hello');
object['intValue'] = 123;
await object.save();
```

### Queries

```dart
LCQuery<LCObject> query = new LCQuery<LCObject>('Hello');
query.limit(limit);
List<LCObject> list = await query.find();
```

### Query Cache

The SDK supports multiple cache policies to optimize performance:

#### Basic Usage

```dart
// Initialize with cache support
LeanCloud.initialize(
  APP_ID, APP_KEY,
  server: APP_SERVER,
  queryCache: new LCQueryCache()
);

// Use cache-first strategy (recommended)
LCQuery<LCObject> query = new LCQuery<LCObject>('Hello');
List<LCObject> list = await query.find(
  cachePolicy: CachePolicy.cacheElseNetwork
);
```

#### Cache Policies

1. **CachePolicy.onlyNetwork** (默认)
   - Always queries from the cloud
   - No cache involved

2. **CachePolicy.networkElseCache** 
   - Queries from cloud first, fallback to cache if failed
   - Good for ensuring fresh data with offline fallback

3. **CachePolicy.onlyCache**
   - Always queries from cache only
   - Throws exception if no cached data available

4. **CachePolicy.cacheElseNetwork** ⭐ (推荐优先使用缓存)
   - Queries from cache first, queries cloud if cache miss
   - Best for performance with fresh data when needed

5. **CachePolicy.cacheFirst**
   - Queries from cache if available and not expired
   - Automatically queries cloud for expired cache

6. **CachePolicy.cacheAndNetwork**
   - Returns cache immediately and updates with network response
   - Best for instant UI updates

#### Advanced Examples

```dart
// Cache-first strategy (recommended for most cases)
LCQuery<LCObject> query = new LCQuery<LCObject>('User');
query.whereEqualTo('city', 'Beijing');
List<LCObject> users = await query.find(
  cachePolicy: CachePolicy.cacheElseNetwork
);

// Only use cache (offline mode)
try {
  List<LCObject> cachedUsers = await query.find(
    cachePolicy: CachePolicy.onlyCache
  );
} catch (e) {
  print('No cached data available');
}

// Network with cache fallback
List<LCObject> reliableUsers = await query.find(
  cachePolicy: CachePolicy.networkElseCache
);

// Smart cache (respects expiration)
List<LCObject> freshUsers = await query.find(
  cachePolicy: CachePolicy.cacheFirst
);

// 🔥 NEW: Custom cache TTL for find() method
List<LCObject> shortCacheUsers = await query.find(
  cachePolicy: CachePolicy.cacheElseNetwork,
  cacheTtlSeconds: 120 // Custom 2-minute cache
);

List<LCObject> longCacheUsers = await query.find(
  cachePolicy: CachePolicy.cacheElseNetwork,
  cacheTtlSeconds: 3600 // Custom 1-hour cache
);

// 🔥 NEW: Custom cache TTL for first() method  
LCObject? firstUser = await query.first(
  cachePolicy: CachePolicy.cacheElseNetwork,
  cacheTtlSeconds: 600 // Custom 10-minute cache
);

LCObject? smartCacheUser = await query.first(
  cachePolicy: CachePolicy.cacheFirst,
  cacheTtlSeconds: 300 // Custom 5-minute cache
);

// 🔥 NEW: Custom cache TTL for get() method
LCObject? user = await query.get(
  'user-id',
  cachePolicy: CachePolicy.networkElseCache,
  cacheTtlSeconds: 300 // Custom 5-minute cache
);

// Custom TTL for first() method  
LCObject? firstUser = await query.first(
  cachePolicy: CachePolicy.cacheElseNetwork,
  cacheTtlSeconds: 600 // Custom 10-minute cache
);
```

#### Cache Management

```dart
// Clear all cache
await LeanCloud.clearAllCache();

// Manual cache control (if needed)
LCQueryCache cache = new LCQueryCache();
String cacheKey = cache.generateCacheKey('User', queryParams);

// Check if cache exists
if (cache.hasCachedResult(cacheKey)) {
  var data = cache.getCachedResult(cacheKey);
}

// Cache custom data with TTL
cache.cacheResult(cacheKey, data, ttlSeconds: 600); // 10 minutes

// Clear specific cache
cache.clearCache(cacheKey);
```

#### Cache Features

- **🚀 High Performance**: Memory-based caching for fast access
- **⏰ TTL Support**: Configurable expiration time (default: 5 minutes)
- **🔄 Auto Cleanup**: Expired cache automatically removed
- **📱 Offline Support**: Works seamlessly in offline scenarios
- **🎯 Smart Policies**: Multiple strategies for different use cases
- **💾 Memory Efficient**: Intelligent memory management

### Files

```dart
LCFile file = await LCFile.fromPath('avatar', './avatar.jpg');
await file.save(onProgress: (int count, int total) {
    print('$count/$total');
    if (count == total) {
        print('done');
    }
});
```

### Users

```dart
await LCUser.login('hello', 'world');
```

### GeoPoints

```dart
LCGeoPoint p1 = new LCGeoPoint(20.0059, 110.3665);
```

## More

### Documentation

- **📖 [Query Cache API Documentation](CACHE_API.md)** - Complete cache API reference
- **🚀 [Quick Start Example](example/quick_start_cache.dart)** - Get started with caching in 5 minutes  
- **💡 [Advanced Cache Example](example/cache_example.dart)** - Comprehensive cache usage examples

### Guides

Refer to [LeanStorage Flutter Guide][guide] for more usage information.
The guide is also available in Chinese ([中文指南][zh]).

[guide]: https://docs.leancloud.app/leanstorage_guide-flutter.html
[zh]: https://leancloud.cn/docs/leanstorage_guide-flutter.html

For LeanMessage, check out [LeanCloud Official Plugin][plugin].

[plugin]: https://pub.dev/packages/leancloud_official_plugin

### Cache Performance Tips

1. **Use `CachePolicy.cacheElseNetwork` for list pages** - Best balance of speed and data freshness
2. **Use `CachePolicy.networkElseCache` for critical data** - Ensures accuracy with offline fallback  
3. **Set appropriate TTL** - 5-10 minutes for lists, 1-2 minutes for user data
4. **Clear cache on user logout** - Maintain data privacy and accuracy
5. **Monitor cache hit rates** - Optimize strategies based on usage patterns
