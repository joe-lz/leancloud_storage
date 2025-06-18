import 'package:leancloud_storage/leancloud.dart';

/// 🔥 LCQuery 缓存功能完整演示
///
/// 展示 find(), first(), get() 方法的自定义缓存时间功能
void main() async {
  // 初始化 LeanCloud（需要替换为真实的配置）
  LeanCloud.initialize(
    'your-app-id',
    'your-app-key',
    server: 'your-server-url',
    queryCache: LCQueryCache(), // 启用查询缓存
  );

  print('🎉 LCQuery 自定义缓存时间功能演示');

  await demonstrateLCQuery();
  await demonstrateLCStatusQuery();

  print('\n✅ 所有演示完成！');
}

/// 演示 LCQuery 的自定义缓存时间功能
Future<void> demonstrateLCQuery() async {
  print('\n=== LCQuery 自定义缓存时间演示 ===');

  LCQuery<LCObject> query = LCQuery<LCObject>('Product');
  query.whereEqualTo('category', 'electronics');
  query.limit(10);

  try {
    // 1. find() 方法的自定义缓存时间
    print('1. find() 方法演示:');

    // 默认参数（使用默认缓存策略和TTL）
    List<LCObject>? products1 = await query.find();
    print('   ✓ 默认参数: ${products1?.length ?? 0} 个产品');

    // 短时间缓存（2分钟）
    List<LCObject>? products2 = await query.find(
      cachePolicy: CachePolicy.cacheElseNetwork,
      cacheTtlSeconds: 120,
    );
    print('   ✓ 缓存优先 + 2分钟TTL: ${products2?.length ?? 0} 个产品');

    // 长时间缓存（30分钟）
    List<LCObject>? products3 = await query.find(
      cachePolicy: CachePolicy.networkElseCache,
      cacheTtlSeconds: 1800,
    );
    print('   ✓ 网络优先 + 30分钟TTL: ${products3?.length ?? 0} 个产品');

    // 2. first() 方法的自定义缓存时间
    print('\n2. first() 方法演示:');

    // 默认参数
    LCObject? firstProduct1 = await query.first();
    print('   ✓ 默认参数: ${firstProduct1?['name'] ?? '产品'}');

    // 缓存优先 + 5分钟TTL
    LCObject? firstProduct2 = await query.first(
      cachePolicy: CachePolicy.cacheElseNetwork,
      cacheTtlSeconds: 300,
    );
    print('   ✓ 缓存优先 + 5分钟TTL: ${firstProduct2?['name'] ?? '产品'}');

    // 智能缓存 + 10分钟TTL
    LCObject? firstProduct3 = await query.first(
      cachePolicy: CachePolicy.cacheFirst,
      cacheTtlSeconds: 600,
    );
    print('   ✓ 智能缓存 + 10分钟TTL: ${firstProduct3?['name'] ?? '产品'}');

    // 3. get() 方法的自定义缓存时间
    print('\n3. get() 方法演示:');

    // 默认参数
    try {
      LCObject? product1 = await query.get('example-product-id');
      print('   ✓ 默认参数: ${product1?['name'] ?? '产品'}');
    } catch (e) {
      print('   ℹ️ 默认参数（示例ID，实际使用时需要真实ID）');
    }

    // 网络优先 + 3分钟TTL
    try {
      LCObject? product2 = await query.get(
        'example-product-id',
        cachePolicy: CachePolicy.networkElseCache,
        cacheTtlSeconds: 180,
      );
      print('   ✓ 网络优先 + 3分钟TTL: ${product2?['name'] ?? '产品'}');
    } catch (e) {
      print('   ℹ️ 网络优先 + 3分钟TTL（示例ID，实际使用时需要真实ID）');
    }

    // 缓存优先 + 15分钟TTL
    try {
      LCObject? product3 = await query.get(
        'example-product-id',
        cachePolicy: CachePolicy.cacheElseNetwork,
        cacheTtlSeconds: 900,
      );
      print('   ✓ 缓存优先 + 15分钟TTL: ${product3?['name'] ?? '产品'}');
    } catch (e) {
      print('   ℹ️ 缓存优先 + 15分钟TTL（示例ID，实际使用时需要真实ID）');
    }
  } catch (e) {
    print('💡 网络错误是正常的，重点是API功能完整');
  }
}

/// 演示 LCStatusQuery 的自定义缓存时间功能
Future<void> demonstrateLCStatusQuery() async {
  print('\n=== LCStatusQuery 自定义缓存时间演示 ===');

  LCStatusQuery statusQuery = LCStatusQuery(inboxType: LCStatus.InboxTypeDefault);
  statusQuery.limit(20);

  try {
    // 1. find() 方法的自定义缓存时间
    print('1. LCStatusQuery find() 方法演示:');

    // 默认参数
    List<LCStatus>? statuses1 = await statusQuery.find();
    print('   ✓ 默认参数: ${statuses1?.length ?? 0} 个状态');

    // 短时间缓存（1分钟）- 状态更新频繁
    List<LCStatus>? statuses2 = await statusQuery.find(
      cachePolicy: CachePolicy.cacheElseNetwork,
      cacheTtlSeconds: 60,
    );
    print('   ✓ 缓存优先 + 1分钟TTL: ${statuses2?.length ?? 0} 个状态');

    // 网络优先 + 2分钟TTL
    List<LCStatus>? statuses3 = await statusQuery.find(
      cachePolicy: CachePolicy.networkElseCache,
      cacheTtlSeconds: 120,
    );
    print('   ✓ 网络优先 + 2分钟TTL: ${statuses3?.length ?? 0} 个状态');

    // 2. first() 方法的自定义缓存时间
    print('\n2. LCStatusQuery first() 方法演示:');

    // 默认参数
    LCStatus? firstStatus1 = await statusQuery.first();
    print('   ✓ 默认参数: ${firstStatus1?['content'] ?? '状态内容'}');

    // 缓存优先 + 90秒TTL
    LCStatus? firstStatus2 = await statusQuery.first(
      cachePolicy: CachePolicy.cacheElseNetwork,
      cacheTtlSeconds: 90,
    );
    print('   ✓ 缓存优先 + 90秒TTL: ${firstStatus2?['content'] ?? '状态内容'}');
  } catch (e) {
    print('💡 状态查询需要用户登录，这里展示API支持');
  }
}

/// 📝 使用建议和最佳实践
void printUsageGuidelines() {
  print('''
  
📝 缓存时间设置建议：

🔥 实时数据（股价、聊天消息）:
   cacheTtlSeconds: 30-60    // 30秒-1分钟

⚡ 频繁更新数据（用户状态、购物车）:
   cacheTtlSeconds: 60-300   // 1-5分钟

📦 一般列表数据（商品、文章）:
   cacheTtlSeconds: 300-600  // 5-10分钟

👤 用户资料数据:
   cacheTtlSeconds: 120-300  // 2-5分钟

⚙️ 配置数据（很少变化）:
   cacheTtlSeconds: 1800-7200 // 30分钟-2小时

📚 静态内容（帮助文档等）:
   cacheTtlSeconds: 86400+   // 1天以上

🎯 缓存策略选择建议：

• CachePolicy.cacheElseNetwork  ⭐ 推荐
  优先使用缓存，快速响应用户

• CachePolicy.networkElseCache
  确保数据新鲜度，支持离线使用

• CachePolicy.cacheFirst
  智能缓存管理，自动处理过期

• CachePolicy.onlyCache
  离线模式，仅使用缓存数据

• CachePolicy.onlyNetwork
  实时数据，总是从网络获取
  ''');
}
