import 'package:leancloud_storage/leancloud.dart';

/// 🚀 LeanCloud 查询缓存快速入门
///
/// 这个示例展示了如何使用 LeanCloud 的查询缓存功能
/// 来提升应用性能和用户体验
void main() async {
  // ⚙️ 初始化 LeanCloud（必需）
  LeanCloud.initialize(
    'your-app-id', // 替换为你的 App ID
    'your-app-key', // 替换为你的 App Key
    server: 'your-server', // 替换为你的服务器地址
    queryCache: LCQueryCache(), // 🔑 启用查询缓存
  );

  print('🎉 LeanCloud 查询缓存快速入门');

  // 🌐 基础用法：默认网络查询
  await networkQueryExample();

  // ⚡ 推荐用法：缓存优先查询
  await cacheFirstQueryExample();

  // 🔄 实用场景：离线可用查询
  await offlineAvailableExample();

  // ⏰ 新功能：自定义缓存时间
  await customCacheTtlExample();

  print('\n✅ 快速入门完成！');
}

/// 🌐 基础网络查询（传统方式）
Future<void> networkQueryExample() async {
  print('\n--- 🌐 网络查询示例 ---');

  LCQuery<LCObject> query = LCQuery<LCObject>('Product');
  query.whereEqualTo('category', 'electronics');
  query.limit(10);

  // 默认行为：总是从网络获取数据
  print('正在从网络获取商品...');
  List<LCObject>? products = await query.find();
  print('✅ 获取到 ${products?.length ?? 0} 个商品');
}

/// ⚡ 缓存优先查询（推荐方式）
Future<void> cacheFirstQueryExample() async {
  print('\n--- ⚡ 缓存优先查询示例 ---');

  LCQuery<LCObject> query = LCQuery<LCObject>('Product');
  query.whereEqualTo('category', 'electronics');
  query.limit(10);

  // 🔥 使用缓存优先策略
  print('正在获取商品（缓存优先）...');
  List<LCObject>? products = await query.find(
    cachePolicy: CachePolicy.cacheElseNetwork, // 🌟 关键配置
  );
  print('⚡ 快速获取到 ${products?.length ?? 0} 个商品');

  // 再次查询，这次会直接从缓存返回（极速）
  print('再次查询相同数据...');
  Stopwatch stopwatch = Stopwatch()..start();
  List<LCObject>? cachedProducts = await query.find(
    cachePolicy: CachePolicy.cacheElseNetwork,
  );
  stopwatch.stop();
  print('🚀 缓存查询仅用时 ${stopwatch.elapsedMilliseconds}ms，获取 ${cachedProducts?.length ?? 0} 个商品');
}

/// 🔄 离线可用查询示例
Future<void> offlineAvailableExample() async {
  print('\n--- 🔄 离线可用查询示例 ---');

  LCQuery<LCObject> query = LCQuery<LCObject>('Article');
  query.orderByDescending('createdAt');
  query.limit(5);

  // 场景1：网络优先，缓存备用（确保数据新鲜度 + 离线可用）
  print('网络优先策略（推荐用于重要数据）...');
  try {
    List<LCObject>? articles = await query.find(
      cachePolicy: CachePolicy.networkElseCache,
    );
    print('📰 获取到 ${articles?.length ?? 0} 篇文章');
  } catch (e) {
    print('❌ 网络错误：$e');
  }

  // 场景2：仅使用缓存（离线模式）
  print('离线模式（仅使用缓存）...');
  try {
    List<LCObject>? cachedArticles = await query.find(
      cachePolicy: CachePolicy.onlyCache,
    );
    print('📱 离线获取到 ${cachedArticles?.length ?? 0} 篇文章');
  } catch (e) {
    print('💡 提示：${e.toString().contains('No cached data') ? '暂无缓存数据' : e}');
  }
}

/// ⏰ 自定义缓存时间示例
Future<void> customCacheTtlExample() async {
  print('\n--- ⏰ 自定义缓存时间示例 ---');

  LCQuery<LCObject> query = LCQuery<LCObject>('Product');
  query.whereEqualTo('category', 'electronics');
  query.limit(10);

  // 场景1：短时间缓存（30秒）- 适合实时性要求高的数据
  print('短时间缓存（30秒）...');
  List<LCObject>? shortCacheProducts = await query.find(
    cachePolicy: CachePolicy.cacheElseNetwork,
    cacheTtlSeconds: 30, // 🔥 自定义30秒缓存
  );
  print('📦 获取到 ${shortCacheProducts?.length ?? 0} 个产品（30秒缓存）');

  // 场景2：中等时间缓存（10分钟）- 适合一般列表数据
  print('中等时间缓存（10分钟）...');
  List<LCObject>? mediumCacheProducts = await query.find(
    cachePolicy: CachePolicy.cacheElseNetwork,
    cacheTtlSeconds: 600, // 🔥 自定义10分钟缓存
  );
  print('📦 获取到 ${mediumCacheProducts?.length ?? 0} 个产品（10分钟缓存）');

  // 场景3：长时间缓存（1小时）- 适合相对静态的数据
  print('长时间缓存（1小时）...');
  LCQuery<LCObject> configQuery = LCQuery<LCObject>('AppConfig');
  List<LCObject>? configData = await configQuery.find(
    cachePolicy: CachePolicy.cacheElseNetwork,
    cacheTtlSeconds: 3600, // 🔥 自定义1小时缓存
  );
  print('⚙️ 获取到 ${configData?.length ?? 0} 个配置项（1小时缓存）');

  // 场景4：获取单个对象（详情页面）
  print('获取单个产品详情（5分钟缓存）...');
  LCQuery<LCObject> detailQuery = LCQuery<LCObject>('Product');
  try {
    LCObject? productDetail = await detailQuery.get(
      'example-product-id',
      cachePolicy: CachePolicy.networkElseCache,
      cacheTtlSeconds: 300, // 🔥 自定义5分钟缓存
    );
    print('📱 获取到产品详情：${productDetail?['name'] ?? '示例产品'}（5分钟缓存）');
  } catch (e) {
    print('💡 提示：这是示例ID，实际使用时请替换为真实的产品ID');
  }

  print('\n💡 使用建议：');
  print('   • 实时数据（股价、聊天）：30秒 - 2分钟');
  print('   • 一般列表数据：5-10分钟');
  print('   • 用户资料：1-2分钟');
  print('   • 静态配置：30分钟 - 2小时');
  print('   • 很少变化的数据：1天+');
}

/// 📚 实际项目中的使用模式
class ProductService {
  /// 商品列表页面（推荐使用缓存优先）
  static Future<List<LCObject>?> getProductList({String? category}) async {
    LCQuery<LCObject> query = LCQuery<LCObject>('Product');
    if (category != null) {
      query.whereEqualTo('category', category);
    }
    query.limit(20);

    // ⚡ 快速响应用户，10分钟缓存适合商品列表
    return await query.find(
      cachePolicy: CachePolicy.cacheElseNetwork,
      cacheTtlSeconds: 600, // 🔥 自定义10分钟缓存
    );
  }

  /// 商品详情页面（推荐网络优先）
  static Future<LCObject?> getProductDetail(String productId) async {
    LCQuery<LCObject> query = LCQuery<LCObject>('Product');

    // 🔄 确保数据准确性，支持离线查看，5分钟缓存
    return await query.get(
      productId,
      cachePolicy: CachePolicy.networkElseCache,
      cacheTtlSeconds: 300, // 🔥 自定义5分钟缓存
    );
  }

  /// 购物车页面（推荐网络优先）
  static Future<List<LCObject>?> getCartItems() async {
    LCQuery<LCObject> query = LCQuery<LCObject>('CartItem');
    // 购物车数据需要实时性，只缓存2分钟
    return await query.find(
      cachePolicy: CachePolicy.networkElseCache,
      cacheTtlSeconds: 120, // 🔥 自定义2分钟缓存
    );
  }

  /// 用户资料（实时性要求高）
  static Future<List<LCObject>?> getUserProfile() async {
    LCQuery<LCObject> query = LCQuery<LCObject>('UserProfile');
    // 用户资料变化较频繁，缓存1分钟
    return await query.find(
      cachePolicy: CachePolicy.networkElseCache,
      cacheTtlSeconds: 60, // 🔥 自定义1分钟缓存
    );
  }

  /// 应用配置（很少变化）
  static Future<List<LCObject>?> getAppConfig() async {
    LCQuery<LCObject> query = LCQuery<LCObject>('AppConfig');
    // 应用配置很少变化，可以长时间缓存
    return await query.find(
      cachePolicy: CachePolicy.cacheElseNetwork,
      cacheTtlSeconds: 3600, // 🔥 自定义1小时缓存
    );
  }
}

/// 💡 性能优化建议
void performanceTips() {
  print('''
  
💡 性能优化建议：

1. 🎯 合理选择缓存策略
   • 列表页面 → CachePolicy.cacheElseNetwork  
   • 详情页面 → CachePolicy.networkElseCache
   • 设置页面 → CachePolicy.onlyNetwork

2. ⏰ 设置合适的缓存时间
   • 商品列表：5-10分钟
   • 用户资料：1-2分钟  
   • 静态配置：1小时+

3. 🧹 定期清理缓存
   • 应用启动时清理过期缓存
   • 用户退出登录时清理用户相关缓存
   • 版本更新时清理所有缓存

4. 📊 监控缓存效果
   • 统计缓存命中率
   • 监控查询响应时间
   • 观察用户体验指标
  ''');
}
