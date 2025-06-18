# LeanCloud Flutter SDK - 查询缓存 API 文档

## 概述

LeanCloud Flutter SDK 提供了强大的查询缓存功能，可以显著提升应用性能和用户体验。通过智能的缓存策略，应用可以实现快速响应、离线可用和数据同步的完美平衡。

## 快速开始

### 1. 初始化缓存

```dart
LeanCloud.initialize(
  'your-app-id',
  'your-app-key',
  server: 'your-server',
  queryCache: LCQueryCache(), // 启用查询缓存
);
```

### 2. 基础使用

```dart
LCQuery<LCObject> query = LCQuery<LCObject>('Product');
List<LCObject>? products = await query.find(
  cachePolicy: CachePolicy.cacheElseNetwork, // 缓存优先
);
```

### 3. 🔥 自定义缓存时间 (新功能)

```dart
LCQuery<LCObject> query = LCQuery<LCObject>('Product');

// find() 方法自定义缓存时间
List<LCObject>? products = await query.find(
  cachePolicy: CachePolicy.cacheElseNetwork,
  cacheTtlSeconds: 600, // 🔥 自定义10分钟缓存
);

// get() 方法自定义缓存时间
LCObject? product = await query.get(
  'product-id',
  cachePolicy: CachePolicy.networkElseCache,
  cacheTtlSeconds: 300, // 🔥 自定义5分钟缓存
);

// first() 方法自定义缓存时间
LCObject? firstProduct = await query.first(
  cachePolicy: CachePolicy.cacheElseNetwork,
  cacheTtlSeconds: 120, // 🔥 自定义2分钟缓存
);
```

**TTL 设置建议：**
- 实时数据：30-120秒
- 一般列表：300-600秒（5-10分钟）
- 静态配置：1800-7200秒（30分钟-2小时）
- 很少变化：86400秒+（1天以上）

## 缓存策略 (CachePolicy)

### CachePolicy.onlyNetwork (默认)
- **行为**: 总是从云端查询
- **适用场景**: 支付、敏感操作、实时数据
- **优势**: 数据绝对最新
- **劣势**: 网络依赖、响应较慢

```dart
List<LCObject>? data = await query.find(
  cachePolicy: CachePolicy.onlyNetwork,
);
```

### CachePolicy.cacheElseNetwork ⭐ **推荐**
- **行为**: 优先使用缓存，缓存未命中时查询网络
- **适用场景**: 列表页面、商品展示、文章列表
- **优势**: 极速响应 + 数据完整性
- **缓存策略**: 智能回退

```dart
List<LCObject>? data = await query.find(
  cachePolicy: CachePolicy.cacheElseNetwork,
);
```

### CachePolicy.networkElseCache
- **行为**: 优先从网络查询，失败时使用缓存
- **适用场景**: 重要数据查询、需要最新数据但支持离线
- **优势**: 数据新鲜度 + 离线可用
- **网络策略**: 优雅降级

```dart
List<LCObject>? data = await query.find(
  cachePolicy: CachePolicy.networkElseCache,
);
```

### CachePolicy.onlyCache
- **行为**: 仅使用缓存数据
- **适用场景**: 离线模式、已知有缓存的场景
- **优势**: 极速响应、零网络消耗
- **注意**: 无缓存时抛出异常

```dart
try {
  List<LCObject>? data = await query.find(
    cachePolicy: CachePolicy.onlyCache,
  );
} catch (e) {
  // 处理无缓存数据的情况
}
```

### CachePolicy.cacheFirst
- **行为**: 缓存未过期时使用缓存，过期时查询网络
- **适用场景**: 数据更新不频繁的场景
- **优势**: 智能缓存管理、自动刷新
- **TTL**: 支持自定义过期时间

```dart
List<LCObject>? data = await query.find(
  cachePolicy: CachePolicy.cacheFirst,
);
```

### CachePolicy.cacheAndNetwork
- **行为**: 立即返回缓存，同时后台更新网络数据
- **适用场景**: 需要即时显示且数据会更新的场景
- **优势**: 最佳用户体验、数据最终一致性
- **实现**: 双重查询机制

```dart
List<LCObject>? data = await query.find(
  cachePolicy: CachePolicy.cacheAndNetwork,
);
```

## LCQueryCache API

### 构造函数

```dart
LCQueryCache cache = LCQueryCache();
```

### 缓存检查

```dart
// 检查缓存是否存在且未过期
bool exists = cache.hasCachedResult(cacheKey);

// 获取缓存数据
dynamic data = cache.getCachedResult(cacheKey);
```

### 缓存管理

```dart
// 缓存数据（默认TTL: 5分钟）
cache.cacheResult(cacheKey, data);

// 自定义TTL缓存
cache.cacheResult(cacheKey, data, ttlSeconds: 600); // 10分钟

// 清除特定缓存
cache.clearCache(cacheKey);

// 清除所有缓存
cache.clearAllCache();
```

### 缓存键生成

```dart
String cacheKey = cache.generateCacheKey(className, queryParams);
```

## 全局缓存管理

### 清除所有缓存

```dart
await LeanCloud.clearAllCache();
```

## 使用模式

### 列表页面模式

```dart
class ProductListPage {
  Future<void> loadProducts() async {
    LCQuery<LCObject> query = LCQuery<LCObject>('Product');
    
    // 快速显示缓存数据，提升用户体验
    List<LCObject>? products = await query.find(
      cachePolicy: CachePolicy.cacheElseNetwork,
    );
    
    // 更新UI
    updateUI(products);
  }
}
```

### 详情页面模式

```dart
class ProductDetailPage {
  Future<void> loadProduct(String productId) async {
    LCQuery<LCObject> query = LCQuery<LCObject>('Product');
    
    // 确保数据准确性，支持离线查看
    LCObject? product = await query.get(productId);
    
    updateUI(product);
  }
}
```

### 实时数据模式

```dart
class OrderPage {
  Future<void> loadOrders() async {
    LCQuery<LCObject> query = LCQuery<LCObject>('Order');
    
    // 订单数据需要最新状态
    List<LCObject>? orders = await query.find(
      cachePolicy: CachePolicy.networkElseCache,
    );
    
    updateUI(orders);
  }
}
```

### 离线模式

```dart
class OfflineMode {
  Future<List<LCObject>?> getCachedData() async {
    LCQuery<LCObject> query = LCQuery<LCObject>('Content');
    
    try {
      return await query.find(
        cachePolicy: CachePolicy.onlyCache,
      );
    } catch (e) {
      // 无缓存数据
      return null;
    }
  }
}
```

## 性能优化建议

### 1. 缓存策略选择

| 场景类型 | 推荐策略 | 原因 |
|---------|----------|------|
| 商品列表 | `cacheElseNetwork` | 快速响应 + 完整数据 |
| 用户资料 | `networkElseCache` | 数据准确性 + 离线可用 |
| 静态配置 | `cacheFirst` | 减少不必要网络请求 |
| 购物车 | `networkElseCache` | 实时性 + 容错性 |
| 支付相关 | `onlyNetwork` | 确保数据安全 |

### 2. TTL 设置建议

```dart
// 商品列表：5-10分钟
cache.cacheResult(key, data, ttlSeconds: 600);

// 用户资料：1-2分钟  
cache.cacheResult(key, data, ttlSeconds: 120);

// 静态配置：1小时
cache.cacheResult(key, data, ttlSeconds: 3600);
```

### 3. 缓存清理策略

```dart
class CacheManager {
  // 应用启动时清理过期缓存
  static Future<void> onAppStart() async {
    // LCQueryCache 会自动清理过期缓存
  }
  
  // 用户退出时清理相关缓存
  static Future<void> onUserLogout() async {
    await LeanCloud.clearAllCache();
  }
  
  // 版本更新时清理所有缓存
  static Future<void> onVersionUpdate() async {
    await LeanCloud.clearAllCache();
  }
}
```

## 错误处理

### 缓存未命中

```dart
try {
  List<LCObject>? data = await query.find(
    cachePolicy: CachePolicy.onlyCache,
  );
} on LCException catch (e) {
  if (e.code == 404) {
    // 无缓存数据，可以引导用户刷新
    print('暂无缓存数据，请检查网络后重试');
  }
}
```

### 网络错误处理

```dart
try {
  List<LCObject>? data = await query.find(
    cachePolicy: CachePolicy.networkElseCache,
  );
} catch (e) {
  // 网络错误会自动回退到缓存
  print('已使用缓存数据，网络恢复后会自动更新');
}
```

## 调试与监控

### 启用调试日志

```dart
LCLogger.setLevel(LCLogger.DebugLevel);
```

### 性能监控

```dart
class CacheMetrics {
  static int cacheHits = 0;
  static int cacheMisses = 0;
  
  static double get hitRate => cacheHits / (cacheHits + cacheMisses);
  
  static void recordHit() => cacheHits++;
  static void recordMiss() => cacheMisses++;
}
```

## 最佳实践

1. **🎯 合理选择缓存策略**: 根据数据重要性和实时性要求选择合适的策略
2. **⏰ 设置合适的TTL**: 平衡数据新鲜度和性能
3. **🧹 定期清理缓存**: 避免内存占用过多
4. **📊 监控缓存效果**: 统计命中率和响应时间
5. **🔄 优雅降级**: 网络失败时提供缓存数据
6. **🛡️ 错误处理**: 妥善处理缓存未命中的情况
7. **📱 考虑离线场景**: 为用户提供离线可用的功能

## 常见问题

### Q: 缓存数据何时过期？
A: 默认5分钟，可通过 `ttlSeconds` 参数自定义。

### Q: 缓存占用多少内存？
A: 仅保存序列化后的JSON数据，内存占用较小。

### Q: 如何清理特定用户的缓存？
A: 目前需要调用 `clearAllCache()`，未来版本会支持按用户清理。

### Q: 缓存是否持久化？
A: 当前版本仅支持内存缓存，应用重启后缓存会清空。

### Q: 支持哪些查询类型？
A: 支持所有 `LCQuery` 查询，包括 `find()`、`first()` 等。
