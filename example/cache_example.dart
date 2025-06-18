import 'package:leancloud_storage/leancloud.dart';

void main() async {
  // 🚀 初始化 LeanCloud 并启用查询缓存
  LeanCloud.initialize(
    'your-app-id',
    'your-app-key',
    server: 'your-server-url',
    queryCache: LCQueryCache(), // 启用查询缓存
  );

  // 启用调试日志
  LCLogger.setLevel(LCLogger.DebugLevel);

  // 📝 基础查询缓存示例
  await basicCacheExample();

  // 🎯 不同缓存策略示例
  await cacheStrategiesExample();

  // 🔧 高级缓存管理示例
  await advancedCacheExample();

  // 👥 用户查询缓存示例
  await userCacheExample();

  // 📊 状态查询缓存示例
  await statusCacheExample();
}

/// 基础查询缓存示例
Future<void> basicCacheExample() async {
  print('\n=== 基础查询缓存示例 ===');

  // 创建查询对象
  LCQuery<LCObject> query = LCQuery<LCObject>('Product');
  query.whereEqualTo('category', 'electronics');
  query.limit(20);

  // 📈 推荐：优先使用缓存策略
  print('使用缓存优先策略...');
  List<LCObject>? products = await query.find(
    cachePolicy: CachePolicy.cacheElseNetwork,
  );
  print('获取到 ${products?.length ?? 0} 个产品');

  // 再次查询，这次会直接从缓存获取
  print('再次查询（将从缓存获取）...');
  List<LCObject>? cachedProducts = await query.find(
    cachePolicy: CachePolicy.cacheElseNetwork,
  );
  print('从缓存获取到 ${cachedProducts?.length ?? 0} 个产品');
}

/// 不同缓存策略示例
Future<void> cacheStrategiesExample() async {
  print('\n=== 缓存策略对比示例 ===');

  LCQuery<LCObject> query = LCQuery<LCObject>('Article');
  query.orderByDescending('createdAt');
  query.limit(10);

  // 1. 仅网络查询（默认）
  print('1. 仅网络查询...');
  try {
    List<LCObject>? networkArticles = await query.find(
      cachePolicy: CachePolicy.onlyNetwork,
    );
    print('网络查询成功：${networkArticles?.length ?? 0} 篇文章');
  } catch (e) {
    print('网络查询失败：$e');
  }

  // 2. 优先缓存策略 ⭐ 推荐
  print('2. 优先缓存策略...');
  List<LCObject>? cacheFirstArticles = await query.find(
    cachePolicy: CachePolicy.cacheElseNetwork,
  );
  print('缓存优先成功：${cacheFirstArticles?.length ?? 0} 篇文章');

  // 3. 仅缓存查询
  print('3. 仅缓存查询...');
  try {
    List<LCObject>? onlyCacheArticles = await query.find(
      cachePolicy: CachePolicy.onlyCache,
    );
    print('仅缓存成功：${onlyCacheArticles?.length ?? 0} 篇文章');
  } catch (e) {
    print('仅缓存失败：$e');
  }

  // 4. 网络优先，缓存备用
  print('4. 网络优先，缓存备用...');
  List<LCObject>? networkElseCacheArticles = await query.find(
    cachePolicy: CachePolicy.networkElseCache,
  );
  print('网络+缓存备用：${networkElseCacheArticles?.length ?? 0} 篇文章');

  // 5. 智能缓存（考虑过期时间）
  print('5. 智能缓存...');
  List<LCObject>? smartCacheArticles = await query.find(
    cachePolicy: CachePolicy.cacheFirst,
  );
  print('智能缓存：${smartCacheArticles?.length ?? 0} 篇文章');
}

/// 高级缓存管理示例
Future<void> advancedCacheExample() async {
  print('\n=== 高级缓存管理示例 ===');

  // 手动缓存管理
  LCQueryCache cache = LCQueryCache();

  // 生成缓存键
  Map<String, dynamic> queryParams = {'where': '{"category":"books"}', 'limit': 10, 'order': '-createdAt'};
  String cacheKey = cache.generateCacheKey('Book', queryParams);
  print('缓存键：$cacheKey');

  // 检查缓存是否存在
  if (cache.hasCachedResult(cacheKey)) {
    print('缓存存在');
    var cachedData = cache.getCachedResult(cacheKey);
    print('缓存数据：$cachedData');
  } else {
    print('缓存不存在');
  }

  // 手动缓存数据（TTL: 10分钟）
  List<Map<String, dynamic>> mockData = [
    {'title': 'Flutter 实战', 'author': '张三'},
    {'title': 'Dart 编程', 'author': '李四'},
  ];
  cache.cacheResult(cacheKey, mockData, ttlSeconds: 600);
  print('已缓存模拟数据');

  // 清除特定缓存
  cache.clearCache(cacheKey);
  print('已清除特定缓存');

  // 清除所有缓存
  cache.clearAllCache();
  print('已清除所有缓存');

  // 全局清除缓存
  await LeanCloud.clearAllCache();
  print('已清除全局缓存');
}

/// 用户查询缓存示例
Future<void> userCacheExample() async {
  print('\n=== 用户查询缓存示例 ===');

  try {
    // 用户查询通常需要实时性，但也可以使用缓存提升性能
    LCQuery<LCUser> userQuery = LCQuery<LCUser>('_User');
    userQuery.whereEqualTo('city', 'Beijing');
    userQuery.limit(20);

    // 场景1：用户列表可以使用缓存
    print('获取用户列表（缓存优先）...');
    List<LCUser>? users = await userQuery.find(
      cachePolicy: CachePolicy.cacheElseNetwork,
    );
    print('获取到 ${users?.length ?? 0} 个用户');

    // 场景2：当前用户信息需要最新数据
    print('获取当前用户（网络优先）...');
    LCUser? currentUser = await LCUser.getCurrent();
    if (currentUser != null) {
      print('当前用户：${currentUser.username}');
    }
  } catch (e) {
    print('用户查询错误：$e');
  }
}

/// 状态查询缓存示例
Future<void> statusCacheExample() async {
  print('\n=== 状态查询缓存示例 ===');

  try {
    // 确保用户已登录
    LCUser? currentUser = await LCUser.getCurrent();
    if (currentUser == null) {
      print('用户未登录，跳过状态查询示例');
      return;
    }

    // 状态查询缓存
    LCStatusQuery statusQuery = LCStatusQuery();
    statusQuery.limit(10);

    // 状态信息可以使用缓存提升加载速度
    print('获取状态列表（缓存优先）...');
    List<LCStatus> statuses = await statusQuery.find(
      cachePolicy: CachePolicy.cacheElseNetwork,
    );
    print('获取到 ${statuses.length} 条状态');
  } catch (e) {
    print('状态查询错误：$e');
  }
}

/// 性能对比示例
Future<void> performanceComparisonExample() async {
  print('\n=== 性能对比示例 ===');

  LCQuery<LCObject> query = LCQuery<LCObject>('Product');
  query.limit(50);

  // 测试网络查询性能
  Stopwatch networkStopwatch = Stopwatch()..start();
  List<LCObject>? networkResults = await query.find(
    cachePolicy: CachePolicy.onlyNetwork,
  );
  networkStopwatch.stop();
  print('网络查询：${networkStopwatch.elapsedMilliseconds}ms，${networkResults?.length ?? 0} 条记录');

  // 测试缓存查询性能
  Stopwatch cacheStopwatch = Stopwatch()..start();
  List<LCObject>? cacheResults = await query.find(
    cachePolicy: CachePolicy.onlyCache,
  );
  cacheStopwatch.stop();
  print('缓存查询：${cacheStopwatch.elapsedMilliseconds}ms，${cacheResults?.length ?? 0} 条记录');

  print('缓存速度提升：${(networkStopwatch.elapsedMilliseconds / cacheStopwatch.elapsedMilliseconds).toStringAsFixed(2)}倍');
}

/// 最佳实践示例
void bestPracticesExample() {
  print('\n=== 最佳实践建议 ===');

  print('''
🎯 缓存策略选择建议：

1. CachePolicy.cacheElseNetwork ⭐ 推荐
   - 适用：列表页面、商品展示、文章列表
   - 优势：快速响应 + 数据更新

2. CachePolicy.networkElseCache
   - 适用：重要数据查询、实时性要求高的场景
   - 优势：数据新鲜度 + 离线可用

3. CachePolicy.onlyCache
   - 适用：离线模式、已知有缓存的场景
   - 优势：极速响应、节省流量

4. CachePolicy.cacheFirst
   - 适用：数据更新不频繁的场景
   - 优势：智能缓存管理

5. CachePolicy.onlyNetwork
   - 适用：用户敏感操作、支付相关
   - 优势：确保最新数据

💡 性能优化提示：
- 合理设置 TTL 时间
- 定期清理过期缓存
- 监控缓存命中率
- 适当的查询条件组合
  ''');
}
